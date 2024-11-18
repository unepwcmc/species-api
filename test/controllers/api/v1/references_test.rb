require 'test_helper'

class Api::V1::ReferencesControllerTest < ActionController::TestCase
  def setup
    @user = FactoryBot.create(:user)
    @admin = FactoryBot.create(:user, role: 'admin')
    @contributor = FactoryBot.create(:user, role: 'default')
    @taxonomy = FactoryBot.create(:taxonomy, name: 'CITES_EU')
    genus = FactoryBot.create(:rank, name: 'GENUS')
    @parent = FactoryBot.create(:taxon_concept, taxonomy: @taxonomy, rank: genus)
    @taxon_concept = FactoryBot.create(:taxon_concept, taxonomy: @taxonomy, parent: @parent)
    @reference1 = FactoryBot.create(:reference, citation: 'AAA')
    @reference2 = FactoryBot.create(:reference, citation: 'BBB')
    FactoryBot.create(:taxon_concept_reference,
      taxon_concept: @parent, reference: @reference1, is_standard: true, is_cascaded: true
    )
    FactoryBot.create(:taxon_concept_reference,
      taxon_concept: @taxon_concept, reference: @reference2, is_standard: true
    )
    ActiveRecord::Base.connection.execute(<<-SQL
      SELECT * FROM rebuild_taxonomy();
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

  test "returns both inherited and taxon-level standard references" do
    @request.headers["X-Authentication-Token"] = @user.authentication_token
    get :index, params: { taxon_concept_id: @taxon_concept.id }

    results = JSON.parse(response.body)
    assert_equal 2, results.size
  end
end
