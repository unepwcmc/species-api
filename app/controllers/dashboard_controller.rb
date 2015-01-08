class DashboardController < ApplicationController
  def index
    @successful_requests = current_user.api_requests.where(response_status: 200)
    @unauthorised_requests = current_user.api_requests.where(response_status: 401)
    @unsuccessful_requests = current_user.api_requests.where(response_status: 500)
  end

  def generate_new_token
    current_user.generate_authentication_token
    render :index, notice: "New token generated successfully!"
  end
end
