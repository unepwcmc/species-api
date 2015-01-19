require 'test_helper'

class Api::V1::CommonNamesControllerTest < ActionController::TestCase
  def setup
    @user = FactoryGirl.create(:user)
    @admin = FactoryGirl.create(:user, role: 'admin')
    @contributor = FactoryGirl.create(:user, role: 'default')
    
    

  end



end