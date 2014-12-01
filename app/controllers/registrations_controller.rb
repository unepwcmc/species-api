class RegistrationsController < Devise::RegistrationsController
  def create
    super { |resource| resource.role = 'api' }
  end
end
