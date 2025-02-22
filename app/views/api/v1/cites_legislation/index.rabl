object @taxon_concept => :cites_legislation

child @cites_listings => :cites_listings do
  node do |cites_listing|
    partial('api/v1/cites_legislation/cites_listing', object: cites_listing)
  end
end

child @cites_quotas => :cites_quotas do
  node do |cites_quota|
    partial('api/v1/cites_legislation/cites_quota', object: cites_quota)
  end
end

child @cites_suspensions => :cites_suspensions do
  node do |cites_suspension|
    partial(
      'api/v1/cites_legislation/cites_suspension', object: cites_suspension
    )
  end
end

