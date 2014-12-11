require 'test_helper'

class Api::V1::TaxonConceptsControllerTest < ActionController::TestCase
  def setup
    @user = FactoryGirl.create(:user)
    @admin = FactoryGirl.create(:user, role: 'admin')
    @contributor = FactoryGirl.create(:user, role: 'default')
  end

  test "should return 401 with no token" do
    get :index
    assert_response 401
  end

  test "should be successful with token" do
    @request.headers["X-Authentication-Token"] = @user.authentication_token

    get :index
    assert_response :success
  end

  test "admin user should be able to access api" do
    @request.headers["X-Authentication-Token"] = @admin.authentication_token

    get :index
    assert_response :success
  end

  test "contributor should not be able to access api" do
    @request.headers["X-Authentication-Token"] = @contributor.authentication_token

    get :index
    assert_response 401
  end

  test "should return page 1 with pagination headers" do
    FactoryGirl.create(:taxon_concept)
    FactoryGirl.create(:taxon_concept)

    @request.headers["X-Authentication-Token"] = @user.authentication_token
    get :index, per_page: 1
    # should report total count of taxa
    assert_equal 2, response['Total-Count'].to_i
    links = LinkHeader.parse(response['Link']).links
    # should return next page header
    assert_not_nil links.find do |lh|
      lh.attr_pairs.include?(['rel', 'next'])
    end
  end

  test "filters results by date with 'updated_since' params" do
    FactoryGirl.create(:taxon_concept, updated_at: 1.year.ago)
    FactoryGirl.create(:taxon_concept, updated_at: 1.month.ago)
    @request.headers["X-Authentication-Token"] = @user.authentication_token

    get :index, updated_since: 2.months.ago.to_s
    results = JSON.parse(response.body)
    assert_equal 1, results.length
  end

  test "filters results by name with 'name' params" do
    FactoryGirl.create(:taxon_concept, full_name: "John Hammond")
    FactoryGirl.create(:taxon_concept, full_name: "Ingen")
    @request.headers["X-Authentication-Token"] = @user.authentication_token
    
    get :index, name: "John Hammond"
    results = JSON.parse(response.body)

    assert_equal "John Hammond", results.first["taxon_concept"]["full_name"]
    assert_equal 1, results.length
  end
end
