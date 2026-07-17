class DebugController < ActionController::Base
  def ip
    render json: {
      remote_ip: request.remote_ip,
      ip: request.ip,
      remote_addr: request.env["REMOTE_ADDR"],
      x_forwarded_for: request.headers["X-Forwarded-For"],
      cf_connecting_ip: request.headers["CF-Connecting-IP"]
    }
  end
end
