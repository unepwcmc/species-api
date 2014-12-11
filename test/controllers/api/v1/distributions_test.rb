require 'test_helper'

class Api::V1::DistributionsControllerTest < ActionController::TestCase
  def setup
    @user = FactoryGirl.create(:user)
    @admin = FactoryGirl.create(:user, role: 'admin')
    @contributor = FactoryGirl.create(:user, role: 'default')

    @distribution = FactoryGirl.create(:distribution)
  end

  test "should return 401 with no token" do
    get :index, id: @distribution.id
    assert_response 401
  end

  test "should be successful with token" do
    @request.headers["X-Authentication-Token"] = @user.authentication_token

    get :index, id: @distribution.id
    assert_response :success
  end

  test "admin user should be able to access api" do
    @request.headers["X-Authentication-Token"] = @admin.authentication_token

    get :index, id: @distribution.id
    assert_response :success
  end

  test "contributor should not be able to access api" do
    @request.headers["X-Authentication-Token"] = @contributor.authentication_token

    get :index, id: @distribution.id
    assert_response 401
  end
end