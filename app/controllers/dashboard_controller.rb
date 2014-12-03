class DashboardController < ApplicationController
  def index
  end

  def generate_new_token
    current_user.generate_new_token
    render :index
  end
end
