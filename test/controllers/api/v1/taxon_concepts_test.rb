require 'test_helper'

class Api::V1::TaxonConceptsControllerTest < ActionController::TestCase
  def setup
    @user = FactoryGirl.create(:user)
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
end
