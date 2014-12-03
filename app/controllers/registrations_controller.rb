class RegistrationsController < Devise::RegistrationsController
  def create
    super { |resource| resource.role = 'api' }
  end

  protected
    def after_sign_up_path_for(resource)
      dashboard_path(resource)
    end
end
