require 'test_helper'

class Api::V1::DownloadsControllerTest < ActionController::TestCase
  include ActiveSupport::Testing::TimeHelpers
  def setup
    @user = FactoryBot.create(:user)
    @admin = FactoryBot.create(:user, role: 'admin')
    @contributor = FactoryBot.create(:user, role: 'default')
    @cites_taxonomy = FactoryBot.create(:taxonomy, name: 'CITES_EU')
    @cites_designation = FactoryBot.create(
      :designation,
      taxonomy: @cites_taxonomy,
      name: 'CITES',
    )

    @download_en = FactoryBot.create(:bulk_download)
    @download_es = FactoryBot.create(
      :bulk_download,
      filters: {
        lang: 'es',
        taxonomy: 'CITES_EU',
      }
    )
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
    @request.headers["X-Authentication-Token"] = @contributor

    get :index
    assert_response 401
  end

  test "returns english download only by default" do
    @request.headers["X-Authentication-Token"] = @user.authentication_token
    get :index, params: { }

    results = JSON.parse(response.body)
    assert_equal 1, results.size
    assert_equal 'en', results[0]['filters']['lang']
  end

  test "returns spanish download only when requested" do
    @request.headers["X-Authentication-Token"] = @user.authentication_token
    get :index, params: { language: 'es' }

    results = JSON.parse(response.body)
    assert_equal 1, results.size
    assert_equal 'es', results[0]['filters']['lang']
  end
end
