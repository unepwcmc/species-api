class StaticPagesController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :authenticate_is_api_or_admin

  def index
  end

  def nomenclature; end
end
