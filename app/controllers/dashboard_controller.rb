class DashboardController < ApplicationController
  before_action :get_stats

  def index
  end

  def generate_new_token
    current_user.generate_authentication_token
    redirect_to dashboard_url, notice: "New token generated successfully!"
  end

  private
  def get_stats
    @all_users_successful_requests = current_user.api_requests.where(response_status: 200)
    @all_users_unsuccessful_requests = current_user.api_requests.where(response_status: 500)
    @users_last_30_days_requests = current_user.api_requests.order(
      :response_status
    ).group(
      :response_status
    ).group_by_day(
      :created_at,
      range: 30.days.ago.midnight..Time.now
    ).count
  end
end
