require 'test_helper'

class Api::V1::ReferencesControllerTest < ActionController::TestCase
  def setup
    @user = FactoryGirl.create(:user)
    @admin = FactoryGirl.create(:user, role: 'admin')
    @contributor = FactoryGirl.create(:user, role: 'default')
    @taxonomy = FactoryGirl.create(:taxonomy, name: 'CITES_EU')
    genus = FactoryGirl.create(:rank, name: 'GENUS')
    @parent = FactoryGirl.create(:taxon_concept, taxonomy: @taxonomy, rank: genus)
    @taxon_concept = FactoryGirl.create(:taxon_concept, taxonomy: @taxonomy, parent: @parent)
    @reference1 = FactoryGirl.create(:reference, citation: 'AAA')
    @reference2 = FactoryGirl.create(:reference, citation: 'BBB')
    FactoryGirl.create(:taxon_concept_reference,
      taxon_concept: @parent, reference: @reference1, is_standard: true, is_cascaded: true
    )
    FactoryGirl.create(:taxon_concept_reference,
      taxon_concept: @taxon_concept, reference: @reference2, is_standard: true
    )
    ActiveRecord::Base.connection.execute(<<-SQL
      SELECT * FROM rebuild_taxonomy();
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

  test "returns both inherited and taxon-level standard references" do
    @request.headers["X-Authentication-Token"] = @user.authentication_token
    get :index, taxon_concept_id: @taxon_concept.id

    results = JSON.parse(response.body)
    assert_equal 2, results.size
  end
end
