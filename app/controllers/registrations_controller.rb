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
      @countries = GeoEntity.where(
        geo_entity_type_id: GeoEntityType.where(
          name: ['COUNTRY', 'REGION', 'TERRITORY']
        ).pluck(:id)
      ).map do |row|
        row.slice(:name, :id)
      end.sort_by! do |row|
        row["name"]
      end.as_json
    end

    def organisations
      @organisations = User.where("organisation IS NOT NULL").pluck("organisation").uniq
    end
end
