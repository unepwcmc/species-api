require 'test_helper'

class Api::V1::CitesLegislationControllerTest < ActionController::TestCase
  def setup
    @user = FactoryGirl.create(:user)
    @admin = FactoryGirl.create(:user, role: 'admin')
    @contributor = FactoryGirl.create(:user, role: 'default')
    @taxon_concept = FactoryGirl.create(:taxon_concept)
    @geo_entity = FactoryGirl.create(:geo_entity)
    @taxon_level_suspension = FactoryGirl.create(:cites_suspension, taxon_concept: @taxon_concept)
    @distribution = FactoryGirl.create(:distribution, taxon_concept: @taxon_concept, geo_entity: @geo_entity)
    @global_suspension = FactoryGirl.create(:cites_suspension, geo_entity: @geo_entity, taxon_concept: nil)
    @historic_suspension = FactoryGirl.create(:cites_suspension, taxon_concept: @taxon_concept, is_current: false)
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
    puts results.inspect
    cites_suspensions = results['cites_legislation']['cites_suspensions']
    assert_equal cites_suspensions.size, 2
  end

  test "returns historic CITES suspensions when historic is specified" do
    @request.headers["X-Authentication-Token"] = @user.authentication_token
    get :index, taxon_concept_id: @taxon_concept.id, historic: true

    results = JSON.parse(response.body)
    cites_suspensions = results['cites_legislation']['cites_suspensions']
    assert_equal cites_suspensions.size, 3
  end

end
