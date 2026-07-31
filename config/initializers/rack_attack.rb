# frozen_string_literal: true

require 'ipaddr'

# Replaces the nginx Lua rate limiter that used to sit in front of this app.
# Puma runs multiple worker processes (and multiple containers behind Kamal's
# proxy), so counters must live in a shared store rather than in-process
# memory - Redis plays the same role here that the nginx shared dict did.
#
# Uses its own Redis DB index (see RACK_ATTACK_REDIS_URL), separate from the
# one Sidekiq uses, so a key collision or a `FLUSHDB` in one doesn't affect
# the other.

# A Redis blip should fail open (skip throttling) rather than take down the
# whole API - every request goes through this store, unlike Sidekiq where a
# Redis outage only delays background jobs.
class RackAttackFailOpenStore
  def initialize(store)
    @store = store
  end

  %i[read write increment delete].each do |method_name|
    define_method(method_name) do |*args, **kwargs|
      @store.public_send(method_name, *args, **kwargs)
    rescue Redis::BaseError => e
      Rails.logger.error("[rack-attack] Redis #{method_name} failed, failing open: #{e.message}")
      nil
    end
  end
end

# Asset precompilation boots Rails without runtime services or secrets - no
# Redis to store counters in and no master key to decrypt the trusted IP list
# with. Skip rate-limit setup for that build-only boot; every real process
# must still provide RACK_ATTACK_REDIS_URL and fail open/empty as configured
# below when its runtime configuration is incomplete.
unless ENV['SECRET_KEY_BASE_DUMMY'] == '1'
  redis_url = ENV.fetch('RACK_ATTACK_REDIS_URL', nil)

  if redis_url
    redis_store = ActiveSupport::Cache::RedisCacheStore.new(url: redis_url)
    Rack::Attack.cache.store = RackAttackFailOpenStore.new(redis_store)
  end

  module RackAttackTiers
    # requests: sustained rate; burst: extra requests allowed on top within the
    # same window before throttling kicks in. Mirrors the old Lua rate_limit
    # table (limit.requests + limit.burst per interval).
    LIMITS = {
      base: { requests: 15, burst: 15, period: 60 },
      trusted: { requests: 30, burst: 15, period: 60 }
    }.freeze

    # Partner-org IP lists live encrypted (config/rack_attack_ips/*.yml.enc)
    # rather than in this public repo, since the list itself reveals which
    # organizations get preferential rate limits. Reuses the same per-environment
    # key as config/credentials - edit with:
    #   bin/rails encrypted:edit config/rack_attack_ips/production.yml.enc \
    #     --key config/credentials/production.key
    # Gracefully empty if the file/key isn't present (e.g. test, or an
    # environment with no partner IPs configured yet).
    ips_config = Rails.application.encrypted(
      "config/rack_attack_ips/#{Rails.env}.yml.enc",
      key_path: "config/credentials/#{Rails.env}.key",
      env_key: 'RAILS_MASTER_KEY'
    )

    # Entries are IPAddr so a bare IP (implicit /32) and a CIDR range match the
    # same way - a plain String#include? would only ever match the literal
    # network address of a subnet, never a host inside it.
    TRUSTED_IPS = Array(ips_config[:trusted_ips]).map { |ip| IPAddr.new(ip) }.freeze
    BLOCKED_IPS = Array(ips_config[:blocked_ips]).map { |ip| IPAddr.new(ip) }.freeze

    def self.match?(list, ip)
      addr = IPAddr.new(ip)
      list.any? { |entry| entry.include?(addr) }
    rescue IPAddr::Error
      false
    end

    def self.for(ip)
      return :trusted if match?(TRUSTED_IPS, ip)

      :base
    end
  end

  # Fully exempt (not just higher-quota) the health-check path itself, e.g.
  # uptime monitors hitting /up - this should never be throttled regardless of
  # where it's called from.
  Rack::Attack.safelist('allow health checks') do |req|
    req.path == '/up'
  end

  # Fully exempt internal/private-network traffic - e.g. kamal-proxy's own
  # health check against the web role, which arrives over the docker network
  # rather than loopback.
  #
  # This is safe against exempting real external traffic: Rack::Request#ip
  # (which req.ip here is) already strips private-range hops (loopback,
  # 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16) from X-Forwarded-For before
  # falling back to them, so a real client behind kamal-proxy resolves to its
  # actual public IP, never to kamal-proxy's own docker-network address. req.ip
  # can only equal a private address here when there's no real public hop in
  # front of it at all - i.e. genuinely internal traffic.
  Rack::Attack.safelist('allow private network') do |req|
    addr = IPAddr.new(req.ip)
    addr.private? || addr.loopback?
  rescue IPAddr::Error
    false
  end

  Rack::Attack.blocklist('block banned ips') do |req|
    RackAttackTiers.match?(RackAttackTiers::BLOCKED_IPS, req.ip)
  end

  RackAttackTiers::LIMITS.each do |tier, limit|
    Rack::Attack.throttle("#{tier} tier", limit: limit[:requests] + limit[:burst], period: limit[:period]) do |req|
      req.ip if RackAttackTiers.for(req.ip) == tier
    end
  end

  ActiveSupport::Notifications.subscribe('throttle.rack_attack') do |_name, _start, _finish, _id, payload|
    req = payload[:request]
    Rails.logger.warn("[rack-attack] throttled ip=#{req.ip} tier=#{req.env['rack.attack.matched']}")
  end

  ActiveSupport::Notifications.subscribe('blocklist.rack_attack') do |_name, _start, _finish, _id, payload|
    req = payload[:request]
    Rails.logger.warn("[rack-attack] blocked ip=#{req.ip}")
  end
end
