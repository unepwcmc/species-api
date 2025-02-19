require 'test_helper'

class DashboardControllerTest < ActionController::TestCase
  def setup
    user = FactoryBot.create(:user)
    sign_in user
  end

  test "should get index" do
    get :index
    assert_response :success
  end
end
