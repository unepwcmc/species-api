require 'test_helper'

class UserSignsInTest < ActionDispatch::IntegrationTest
  def setup
    @user = FactoryGirl.create(:user)
  end

  test "user signs in with valid information" do
    sign_in @user
    assert page.has_content?("API Dashboard")
  end 
end
