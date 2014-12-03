require 'test_helper'

class Api::V1::TaxonConceptsControllerTest < ActionController::TestCase
  def setup
    @user = FactoryGirl.create(:user)
  end

  test "should return 401 with no token" do
    get :index
    assert_response 401
  end

  test "should be successful with token" do
    get :index, user_email: @user.email, user_token: @user.authentication_token
    assert_response :success
  end

  test "subsequent request after successful request should return 401 with no token (every request needs a token)" do
    get :index, user_email: @user.email, user_token: @user.authentication_token
    assert_response :success

    get :index
    assert_response 401
  end
end
