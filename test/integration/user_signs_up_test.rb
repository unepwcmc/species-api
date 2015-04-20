require 'test_helper'

class UserSignsUpTest < ActionDispatch::IntegrationTest
  def setup
    @user = FactoryGirl.build(:user)
  end

  test "user signs up with valid information" do
    assert_difference 'User.count' do
      sign_up @user
    end
    assert_equal 'api', User.last.role
  end

  test "user signs up without accepting terms and conditions" do
    assert_no_difference 'User.count' do
      sign_up @user, terms_and_conditions: false
    end
    #assert_equal 'new_user_registration_path', current_path
  end

  test "user signs up without organisation" do
    @user = FactoryGirl.build(:user, organisation: nil)
    assert_no_difference 'User.count' do
      sign_up @user
    end
  end

  test "user gets an api token on sign up" do
    sign_up @user
    assert_not_nil User.last.authentication_token
  end
end
