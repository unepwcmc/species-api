require 'test_helper'

class Api::V1::EuLegislationControllerTest < ActionController::TestCase
  def setup
    @taxonomy = FactoryGirl.create(:taxonomy, name: 'CITES_EU')
    @eu_designation = FactoryGirl.create(:designation, taxonomy: @taxonomy, name: 'EU')
    @user = FactoryGirl.create(:user)
    @admin = FactoryGirl.create(:user, role: 'admin')
    @contributor = FactoryGirl.create(:user, role: 'default')
    @taxon_concept = FactoryGirl.create(:taxon_concept,
      taxonomy: @taxonomy,
      parent: FactoryGirl.create(:taxon_concept,
        rank: FactoryGirl.create(:rank, name: 'GENUS', display_name_en: 'Genus'),
        taxon_name: FactoryGirl.create(:taxon_name, scientific_name: 'Canis')
      )
    )
    @country_geo_entity_type = FactoryGirl.create(:geo_entity_type, name: 'COUNTRY')
    @geo_entity = FactoryGirl.create(:geo_entity, geo_entity_type: @country_geo_entity_type)
    @distribution = FactoryGirl.create(:distribution, taxon_concept: @taxon_concept, geo_entity: @geo_entity)
    @current_start_event = FactoryGirl.create(:eu_suspension_regulation,  designation: @eu_designation, is_current: true)
    @historic_start_event = FactoryGirl.create(:eu_suspension_regulation, designation: @eu_designation,  is_current: false)
    @suspension = FactoryGirl.create(:eu_suspension,
      taxon_concept: @taxon_concept,
      start_event: @current_start_event
    )
    @opinion = FactoryGirl.create(:eu_opinion, taxon_concept: @taxon_concept)
    @historic_suspension = FactoryGirl.create(:eu_suspension,
      taxon_concept: @taxon_concept, start_event: @historic_start_event, is_current: false
    )
    @addition_change_type = FactoryGirl.create(:change_type, designation: @eu_designation, name: 'ADDITION')
    @deletion_change_type = FactoryGirl.create(:change_type, designation: @eu_designation, name: 'DELETION')
    @reservation_change_type = FactoryGirl.create(:change_type, designation: @eu_designation, name: 'RESERVATION')
    @annexA_species_listing = FactoryGirl.create(:species_listing,
      designation: @eu_designation, name: 'Annex A', abbreviation: 'A'
    )
    @annexB_species_listing = FactoryGirl.create(:species_listing,
      designation: @eu_designation, name: 'Annex B', abbreviation: 'B'
    )
    @current_eu_regulation = FactoryGirl.create(:eu_regulation, is_current: true)
    @historic_eu_regulation = FactoryGirl.create(:eu_regulation, is_current: false)
    @annexA_listing = FactoryGirl.create(:listing_change,
      taxon_concept: @taxon_concept,
      change_type: @addition_change_type,
      species_listing: @annexA_species_listing,
      event: @current_eu_regulation,
      is_current: true
    )
    @annexA_reservation = FactoryGirl.create(:listing_change,
      taxon_concept: @taxon_concept,
      change_type: @reservation_change_type,
      species_listing: @annexA_species_listing,
      event: @current_eu_regulation,
      is_current: true
    )
    @annexB_listing = FactoryGirl.create(:listing_change,
      taxon_concept: @taxon_concept,
      change_type: @addition_change_type,
      species_listing: @annexB_species_listing,
      event: @historic_eu_regulation,
      is_current: false
    )
    ActiveRecord::Base.connection.execute(<<-SQL
      SELECT * FROM rebuild_taxonomy();
      SELECT * FROM rebuild_cites_eu_taxon_concepts_and_ancestors_mview();
      SELECT * FROM rebuild_eu_listing_changes_mview()
    SQL
    )
  end

  test "should return 401 with no token" do
    get :index, params: { taxon_concept_id: @taxon_concept.id }
    assert_response 401
  end

  test "should be successful with token" do
    @request.headers["X-Authentication-Token"] = @user.authentication_token

    get :index, params: { taxon_concept_id: @taxon_concept.id }
    assert_response :success
  end

  test "admin user should be able to access api" do
    @request.headers["X-Authentication-Token"] = @admin.authentication_token

    get :index, params: { taxon_concept_id: @taxon_concept.id }
    assert_response :success
  end

  test "contributor should not be able to access api" do
    @request.headers["X-Authentication-Token"] = @contributor.authentication_token

    get :index, params: { taxon_concept_id: @taxon_concept.id }
    assert_response 401
  end

  test "returns both EU opinions and suspensions" do
    @request.headers["X-Authentication-Token"] = @user.authentication_token
    get :index, params: { taxon_concept_id: @taxon_concept.id }

    results = JSON.parse(response.body)
    eu_decisions = results['eu_decisions']
    assert_equal 2, eu_decisions.size
  end

  test "returns both current and historic EU decisions when requested" do
    @request.headers["X-Authentication-Token"] = @user.authentication_token
    get :index, params: { taxon_concept_id: @taxon_concept.id, scope: :all }

    results = JSON.parse(response.body)
    eu_decisions = results['eu_decisions']
    assert_equal 3, eu_decisions.size
  end

  test "returns both annex listings and reservations" do
    @request.headers["X-Authentication-Token"] = @user.authentication_token
    get :index, params: { taxon_concept_id: @taxon_concept.id }

    results = JSON.parse(response.body)
    eu_listings = results['eu_listings']
    assert_equal 2, eu_listings.size
  end

  test "returns both current and historic listings and reservations when requested" do
    @request.headers["X-Authentication-Token"] = @user.authentication_token
    get :index, params: { taxon_concept_id: @taxon_concept.id, scope: :all }

    results = JSON.parse(response.body)
    eu_listings = results['eu_listings']
    assert_equal 3, eu_listings.size
  end

end
