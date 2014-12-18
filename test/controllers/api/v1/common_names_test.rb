require 'test_helper'

class Api::V1::CommonNamesControllerTest < ActionController::TestCase
  def setup
    @user = FactoryGirl.create(:user)
    @admin = FactoryGirl.create(:user, role: 'admin')
    @contributor = FactoryGirl.create(:user, role: 'default')
    @taxon_concept = FactoryGirl.create(:taxon_concept)
    
    @lang_en = FactoryGirl.create(:language, iso_code1: 'EN')
    @lang_pl = FactoryGirl.create(:language, iso_code1: 'PL')
    @lang_itc = FactoryGirl.create(:language, iso_code1: 'IT')

    FactoryGirl.create(:common_name, taxon_concept: @taxon_concept, language: @lang_en)
    FactoryGirl.create(:common_name, taxon_concept: @taxon_concept, language: @lang_pl)
    FactoryGirl.create(:common_name, taxon_concept: @taxon_concept, language: @lang_it)
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

  test "it returns all common names with no language parameter" do
    @request.headers["X-Authentication-Token"] = @contributor.authentication_token
    get :index, taxon_concept_id: @taxon_concept.id
    results = JSON.parse(response.body)
    assert_equal 3, results.length
  end

  test "it returns correct countries with a single language parameter" do
    @request.headers["X-Authentication-Token"] = @contributor.authentication_token
    get :index, taxon_concept_id: @taxon_concept.id, language: 'PL'
    results = JSON.parse(response.body)
    assert_equal 'PL', results.first["common_name"]["language"]
    assert_equal 1, results.length
  end

  test "it returns correct countries with an array in the language parameter" do
    @request.headers["X-Authentication-Token"] = @contributor.authentication_token
    get :index, taxon_concept_id: @taxon_concept.id, language: 'PL,IT'
    results = JSON.parse(response.body)
    assert_equal 'PL', results.first["common_name"]["language"]
    assert_equal 'IT', results.last["common_name"]["language"]
    assert_equal 2, results.length
  end
end