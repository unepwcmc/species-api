require 'test_helper'

class StaticPagesControllerTest < ActionController::TestCase
  def setup
    user = FactoryGirl.create(:user)
    sign_in user
  end

  test "should get index" do
    get :index
    assert_response :success
  end

end
