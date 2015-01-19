require 'test_helper'

class Api::V1::CitesLegislationControllerTest < ActionController::TestCase
  def setup
    @user = FactoryGirl.create(:user)
    @admin = FactoryGirl.create(:user, role: 'admin')
    @contributor = FactoryGirl.create(:user, role: 'default')
    @taxonomy = FactoryGirl.create(:taxonomy, name: 'CITES_EU')
    @taxon_concept = FactoryGirl.create(:taxon_concept,
      taxonomy: @taxonomy,
      parent: FactoryGirl.create(:taxon_concept,
        rank: FactoryGirl.create(:rank, name: 'GENUS', display_name_en: 'Genus'),
        taxon_name: FactoryGirl.create(:taxon_name, scientific_name: 'Canis')
      )
    )
    @country_geo_entity_type = FactoryGirl.create(:geo_entity_type, name: 'COUNTRY')
    @geo_entity = FactoryGirl.create(:geo_entity, geo_entity_type: @country_geo_entity_type)
    @taxon_level_suspension = FactoryGirl.create(:cites_suspension, taxon_concept: @taxon_concept)
    @distribution = FactoryGirl.create(:distribution, taxon_concept: @taxon_concept, geo_entity: @geo_entity)
    @global_suspension = FactoryGirl.create(:cites_suspension, geo_entity: @geo_entity, taxon_concept: nil)
    @historic_suspension = FactoryGirl.create(:cites_suspension, taxon_concept: @taxon_concept, is_current: false)
    @taxon_level_quota = FactoryGirl.create(:quota, taxon_concept: @taxon_concept)
    @global_quota = FactoryGirl.create(:quota, geo_entity: @geo_entity, taxon_concept: nil)
    @historic_quota = FactoryGirl.create(:quota, taxon_concept: @taxon_concept, is_current: false)
    @cites_designation = FactoryGirl.create(:designation, taxonomy: @taxonomy, name: 'CITES')
    @addition_change_type = FactoryGirl.create(:change_type, designation: @cites_designation, name: 'ADDITION')
    @deletion_change_type = FactoryGirl.create(:change_type, designation: @cites_designation, name: 'DELETION')
    @reservation_change_type = FactoryGirl.create(:change_type, designation: @cites_designation, name: 'RESERVATION')
    @appendixI_species_listing = FactoryGirl.create(:species_listing,
      designation: @cites_designation, name: 'Appendix I', abbreviation: 'I'
    )
    @appendixII_species_listing = FactoryGirl.create(:species_listing,
      designation: @cites_designation, name: 'Appendix II', abbreviation: 'II'
    )
    @appendixI_listing = FactoryGirl.create(:listing_change,
      taxon_concept: @taxon_concept,
      change_type: @addition_change_type,
      species_listing: @appendixI_species_listing,
      is_current: true
    )
    @appendixI_reservation = FactoryGirl.create(:listing_change,
      taxon_concept: @taxon_concept,
      change_type: @reservation_change_type,
      species_listing: @appendixI_species_listing,
      is_current: true
    )
    @appendixII_listing = FactoryGirl.create(:listing_change,
      taxon_concept: @taxon_concept,
      change_type: @addition_change_type,
      species_listing: @appendixII_species_listing,
      is_current: false
    )
    ActiveRecord::Base.connection.execute(<<-SQL
      SELECT * FROM rebuild_taxonomy();
      SELECT * FROM rebuild_cites_eu_taxon_concepts_and_ancestors_mview();
      SELECT * FROM rebuild_cites_listing_changes_mview()
    SQL
    )
  end

  test "should return 401 with no token" do
    get :index, taxon_concept_id: @taxon_concept.id
    assert_response 401
  end

  test "should be successful with token" do
    @request.headers["X-Authentication-Token"] = @user.authentication_token

    get :index, taxon_concept_id: @taxon_concept.id
    assert_response :success
  end

  test "admin user should be able to access api" do
    @request.headers["X-Authentication-Token"] = @admin.authentication_token

    get :index, taxon_concept_id: @taxon_concept.id
    assert_response :success
  end

  test "contributor should not be able to access api" do
    @request.headers["X-Authentication-Token"] = @contributor.authentication_token

    get :index, taxon_concept_id: @taxon_concept.id
    assert_response 401
  end

  test "returns both taxon-level and global CITES suspensions" do
    @request.headers["X-Authentication-Token"] = @user.authentication_token
    get :index, taxon_concept_id: @taxon_concept.id

    results = JSON.parse(response.body)
    cites_suspensions = results['cites_suspensions']
    assert_equal 2, cites_suspensions.size
  end

  test "returns both current and historic CITES suspensions when requested" do
    @request.headers["X-Authentication-Token"] = @user.authentication_token
    get :index, taxon_concept_id: @taxon_concept.id, scope: :all

    results = JSON.parse(response.body)
    cites_suspensions = results['cites_suspensions']
    assert_equal 3, cites_suspensions.size
  end

  test "returns both taxon-level and global CITES quotas" do
    @request.headers["X-Authentication-Token"] = @user.authentication_token
    get :index, taxon_concept_id: @taxon_concept.id

    results = JSON.parse(response.body)
    cites_quotas = results['cites_quotas']
    assert_equal 2, cites_quotas.size
  end

  test "returns both current and historic CITES quotas when requested" do
    @request.headers["X-Authentication-Token"] = @user.authentication_token
    get :index, taxon_concept_id: @taxon_concept.id, scope: :all

    results = JSON.parse(response.body)
    cites_quotas = results['cites_quotas']
    assert_equal 3, cites_quotas.size
  end

  test "returns both appendix listings and reservations" do
    @request.headers["X-Authentication-Token"] = @user.authentication_token
    get :index, taxon_concept_id: @taxon_concept.id

    results = JSON.parse(response.body)
    cites_quotas = results['cites_listings']
    assert_equal 2, cites_quotas.size
  end

  test "returns both current and historic listings and reservations when requested" do
    @request.headers["X-Authentication-Token"] = @user.authentication_token
    get :index, taxon_concept_id: @taxon_concept.id, scope: :all

    results = JSON.parse(response.body)
    cites_quotas = results['cites_listings']
    assert_equal 3, cites_quotas.size
  end

end
