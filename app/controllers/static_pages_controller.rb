class StaticPagesController < ApplicationController
  skip_before_action :authenticate_user!
  
  def index
  end

  def nomenclature; end
end
