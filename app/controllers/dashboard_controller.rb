class DashboardController < ApplicationController
  def index
  end

  def generate_new_token
    current_user.generate_authentication_token
    render :index, notice: "New token generated successfully!"
  end
end
