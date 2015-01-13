class RegistrationsController < Devise::RegistrationsController
  before_action :countries, :only => [:new, :create]
  before_action :organisations, :only => [:new, :create]

  def create
    super { |resource| resource.role = 'api' }
  end

  protected
    def after_sign_up_path_for(resource)
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
