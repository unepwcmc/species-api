require 'test_helper'

class UserSignsInTest < ActionDispatch::IntegrationTest
  def setup
    @user = FactoryGirl.create(:user)
    @admin = FactoryGirl.create(:user, role: 'admin')
    @contributor = FactoryGirl.create(:user, role: 'default')
  end

  test "user signs in with valid information" do
    sign_in @user
    assert page.has_content?("API Dashboard")
  end 

  test "admin user can also access the API" do
    sign_in @admin
    assert page.has_content?("API Dashboard")
  end

  test "default user cannot access API dashboard" do
    sign_in @contributor
    save_and_open_page
    assert page.has_content?("Sign up")
    assert page.has_no_content?("API Dashboard")
  end
end
