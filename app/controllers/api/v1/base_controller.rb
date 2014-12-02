class Api::V1::BaseController < Api::BaseController
  acts_as_token_authentication_handler_for User, fallback_to_devise: false
  skip_before_filter :authenticate_user!
end
