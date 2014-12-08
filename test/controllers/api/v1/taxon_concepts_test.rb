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
    @request.headers["X-Authentication-Token"] = @user.authentication_token

    get :index
    assert_response :success
  end
end
