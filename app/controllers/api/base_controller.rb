class Api::BaseController < ApplicationController
  skip_before_filter :authenticate_user!
  acts_as_token_authentication_handler_for User
end