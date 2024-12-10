require 'test_helper'

class Api::V1::DistributionsControllerTest < ActionController::TestCase
  def setup
    @user = FactoryBot.create(:user)
    @admin = FactoryBot.create(:user, role: 'admin')
    @contributor = FactoryBot.create(:user, role: 'default')
    @taxon_concept = FactoryBot.create(:taxon_concept)
    @distribution = FactoryBot.create(:distribution, taxon_concept_id: @taxon_concept.id)
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

  test "returns language specific name with language params" do
    @request.headers["X-Authentication-Token"] = @user.authentication_token
    get :index, params: { taxon_concept_id: @taxon_concept.id, language: 'fr' }

    results = JSON.parse(response.body)
    assert_equal "name fr", results.first["name"]
  end

  test "defaults to English name without language params" do
    @request.headers["X-Authentication-Token"] = @user.authentication_token
    get :index, params: { taxon_concept_id: @taxon_concept.id }

    results = JSON.parse(response.body)
    assert_equal "name en", results.first["name"]
  end
end
