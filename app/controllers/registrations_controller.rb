class RegistrationsController < Devise::RegistrationsController
  before_action :countries, :only => [:new, :create, :edit, :update]
  before_action :organisations, :only => [:new, :create, :edit, :update]

  def new
    build_resource({organisation: nil, is_cites_authority: nil, role: 'api'})
    @validatable = devise_mapping.validatable?
    if @validatable
      @minimum_password_length = resource_class.password_length.min
    end
    respond_with self.resource
  end

  protected
    def after_sign_up_path_for(resource)
      dashboard_path
    end

    def after_update_path_for(resource)
      dashboard_path
    end

  private
    def countries
      @countries = HTTParty.get("http://www.speciesplus.net/api/v1/geo_entities.json?geo_entity_types_set=2&locale=en")
      if @countries.code != 200
        @countries = []
      end
    end

    def organisations
      @organisations = User.where("organisation IS NOT NULL").pluck("organisation").uniq
    end
end
