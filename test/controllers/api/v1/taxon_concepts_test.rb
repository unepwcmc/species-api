require 'test_helper'

class Api::V1::TaxonConceptsControllerTest < ActionController::TestCase
  include ActiveSupport::Testing::TimeHelpers
  def setup
    @user = FactoryBot.create(:user)
    @admin = FactoryBot.create(:user, role: 'admin')
    @contributor = FactoryBot.create(:user, role: 'default')
    @cites = FactoryBot.create(:taxonomy, name: 'CITES_EU')
  end

  def create_common_names
    @lang_en = FactoryBot.create(:language, iso_code1: 'EN')
    @lang_pl = FactoryBot.create(:language, iso_code1: 'PL')
    @lang_it = FactoryBot.create(:language, iso_code1: 'IT')

    @en_name = FactoryBot.create(:common_name, language: @lang_en)
    @pl_name = FactoryBot.create(:common_name, language: @lang_pl)
    @it_name = FactoryBot.create(:common_name, language: @lang_it)

    @taxon_concept = FactoryBot.create(:taxon_concept)
    FactoryBot.create(:taxon_common, common_name: @en_name, taxon_concept: @taxon_concept)
    FactoryBot.create(:taxon_common, common_name: @pl_name, taxon_concept: @taxon_concept)
    FactoryBot.create(:taxon_common, common_name: @it_name, taxon_concept: @taxon_concept)
  end

  def create_taxon_concept_tree
    kingdom = FactoryBot.create(:taxon_concept, taxon_name: FactoryBot.create(:taxon_name, scientific_name: 'Animalia'),
      rank: FactoryBot.create(:rank, name: 'KINGDOM', display_name_en: 'Kingdom'))

    phylum = FactoryBot.create(:taxon_concept, parent: kingdom,
      taxon_name: FactoryBot.create(:taxon_name, scientific_name: 'Chordata'), rank: FactoryBot.create(:rank, name: 'PHYLUM', display_name_en: 'Phylum'))
    @klass = FactoryBot.create(:taxon_concept, parent: phylum,
      taxon_name: FactoryBot.create(:taxon_name, scientific_name: 'Mammalia'),
      rank: FactoryBot.create(:rank, name: 'CLASS', display_name_en: 'Class')
    )
    order = FactoryBot.create(:taxon_concept, parent: @klass,
      taxon_name: FactoryBot.create(:taxon_name, scientific_name: 'Psittaciformes'),
      rank: FactoryBot.create(:rank, name: 'ORDER', display_name_en: 'Order')
    )
    family = FactoryBot.create(:taxon_concept, parent: order,
      taxon_name: FactoryBot.create(:taxon_name, scientific_name: 'Psittacidae'),
      rank: FactoryBot.create(:rank, name: 'FAMILY', display_name_en: 'Family')
    )
    genus = FactoryBot.create(:taxon_concept, parent: family,
      taxon_name: FactoryBot.create(:taxon_name, scientific_name: 'Psittacus'),
      rank: FactoryBot.create(:rank, name: 'GENUS', display_name_en: 'Genus')
    )

    taxon_concept = FactoryBot.create(:taxon_concept,
      parent: genus, taxon_name: FactoryBot.create(:taxon_name, scientific_name: 'WRGTEH'),
      rank: FactoryBot.create(:rank, name: 'SPECIES', display_name_en: "Species")
    )

    ActiveRecord::Base.connection.execute(<<-SQL
      SELECT * FROM rebuild_taxonomy();
    SQL
    )
  end

  def create_canis_tree_and_taxon_concepts
    order = FactoryBot.create(:taxon_concept, parent: @klass,
      taxon_name: FactoryBot.create(:taxon_name, scientific_name: 'Carnivora'),
      rank: FactoryBot.create(:rank, name: 'ORDER', display_name_en: 'Order')
    )
    family = FactoryBot.create(:taxon_concept, parent: order,
      taxon_name: FactoryBot.create(:taxon_name, scientific_name: 'Canidae'),
      rank: FactoryBot.create(:rank, name: 'FAMILY', display_name_en: 'Family')
    )

    genus_rank = FactoryBot.create(:rank, name: 'GENUS', display_name_en: 'Genus')

    genus = FactoryBot.create(:taxon_concept, parent: family,
      taxon_name: FactoryBot.create(:taxon_name, scientific_name: 'Canis'),
      rank: genus_rank
    )

    other_genus = FactoryBot.create(:taxon_concept, parent: family,
      taxon_name: FactoryBot.create(:taxon_name, scientific_name: 'Testus'),
      rank: genus_rank
    )

    species_rank = FactoryBot.create(:rank, name: 'SPECIES', display_name_en: "Species")

    taxon_concept = FactoryBot.create(:taxon_concept,
      parent: genus, taxon_name: FactoryBot.create(:taxon_name, scientific_name: 'lupus'),
      rank: species_rank
    )

    other_taxon_concept = FactoryBot.create(:taxon_concept,
      parent: other_genus, taxon_name: FactoryBot.create(:taxon_name, scientific_name: 'Canis'),
      rank: species_rank
    )

    ActiveRecord::Base.connection.execute(<<-SQL
      SELECT * FROM rebuild_taxonomy();
    SQL
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
    @request.headers["X-Authentication-Token"] = @contributor.authentication_token

    get :index
    assert_response 401
  end

  test "should return page 1 with pagination headers" do
    tc = FactoryBot.create(:taxon_concept, taxonomy: @cites)
    FactoryBot.create(:taxon_concept, taxonomy: @cites)

    @request.headers["X-Authentication-Token"] = @user.authentication_token
    get :index, params: { per_page: 1 }
    # should report total count of taxa
    assert_equal 2, response['Total-Count'].to_i
    links = LinkHeader.parse(response['Link']).links
    # should return next page header
    assert_not_nil links.find do |lh|
      lh.attr_pairs.include?(['rel', 'next'])
    end
  end

  test "should return deleted taxa with active=false" do
    tc = FactoryBot.create(:taxon_concept, taxonomy: @cites)
    tc.destroy # version object is stored at this point

    @request.headers["X-Authentication-Token"] = @user.authentication_token
    get :index
    results = JSON.parse(response.body)

    assert_equal 1, results['taxon_concepts'].length
    assert_equal false, results['taxon_concepts'].first["active"]
  end

  test "filters results by date with 'updated_since' params" do
    travel -1.year do
      FactoryBot.create(:taxon_concept, taxonomy: @cites)
    end
    travel -1.month do
      FactoryBot.create(:taxon_concept, taxonomy: @cites)
    end
    @request.headers["X-Authentication-Token"] = @user.authentication_token

    get :index, params: { updated_since: 2.months.ago.to_s }
    results = JSON.parse(response.body)
    assert_equal 1, results['taxon_concepts'].length
  end

  test "returns taxa with self or dependents updated_since" do
    tc = nil
    travel -1.year do
      tc = FactoryBot.create(:taxon_concept, taxonomy: @cites)
      FactoryBot.create(:taxon_concept, taxonomy: @cites)
    end
    travel -1.month do
      FactoryBot.create(:distribution, taxon_concept: tc, updated_at: 1.month.ago)
    end
    @request.headers["X-Authentication-Token"] = @user.authentication_token

    get :index, params: { updated_since: 2.months.ago.to_s }
    results = JSON.parse(response.body)
    assert_equal 1, results['taxon_concepts'].length
  end

  test "filters results by name with 'name' params (case insensitive)" do
    FactoryBot.create(
      :taxon_concept,
      taxon_name: FactoryBot.create(
        :taxon_name, scientific_name: "John Hammond"
      ),
      taxonomy: @cites
    )
    FactoryBot.create(
      :taxon_concept,
      taxon_name: FactoryBot.create(
        :taxon_name, scientific_name: "Ingen"
      ),
      taxonomy: @cites
    )
    @request.headers["X-Authentication-Token"] = @user.authentication_token

    get :index, params: { name: "JOHN HAMMOND" }
    results = JSON.parse(response.body)

    assert_equal "John Hammond", results['taxon_concepts'].first["full_name"]
    assert_equal 1, results['taxon_concepts'].length
  end

  test "filters results by name including higher taxa fields with 'with_descendants' params set to true" do
    create_taxon_concept_tree

    @request.headers["X-Authentication-Token"] = @user.authentication_token
    get :index, params: { name: "Mammalia", with_descendants: 'true' }

    results = JSON.parse(response.body)
    assert_equal 5, results['taxon_concepts'].length

    create_canis_tree_and_taxon_concepts

    get :index, params: { name: "Canis", with_descendants: 'true' }
    results = JSON.parse(response.body)
    assert_equal 2, results['taxon_concepts'].length

  end

  test "filters results by name without 'with_descendants' params does not return tree" do
    create_taxon_concept_tree

    @request.headers["X-Authentication-Token"] = @user.authentication_token
    get :index, params: { name: "Mammalia" }

    results = JSON.parse(response.body)
    assert_equal 1, results['taxon_concepts'].length
  end

  test "filters results by name with 'taxonomy' params" do
    cms = FactoryBot.create(:taxonomy, name: 'CMS')
    cites_tc = FactoryBot.create(:taxon_concept, taxonomy: @cites)
    cms_tc = FactoryBot.create(:taxon_concept, taxonomy: cms)
    @request.headers["X-Authentication-Token"] = @user.authentication_token

    get :index, params: { taxonomy: "CMS" }
    results = JSON.parse(response.body)

    assert_equal cms_tc.id, results['taxon_concepts'].first["id"]
    assert_equal 1, results['taxon_concepts'].length
  end

  test "it returns all common names with no language parameter" do
    create_common_names
    @request.headers["X-Authentication-Token"] = @user.authentication_token
    get :index, params: { name: @taxon_concept.full_name }
    results = JSON.parse(response.body)
    taxon_concept = results['taxon_concepts'].first
    common_names = taxon_concept['common_names']
    assert_equal 3, common_names.length
  end

  test "it returns correct countries with a single language parameter" do
    create_common_names
    @request.headers["X-Authentication-Token"] = @user.authentication_token
    get :index, params: { name: @taxon_concept.full_name, language: 'PL' }
    results = JSON.parse(response.body)
    taxon_concept = results['taxon_concepts'].first
    common_names = taxon_concept['common_names']
    assert_equal 'PL', common_names.first["language"]
    assert_equal 1, common_names.length
  end

  test "it returns correct countries with an array in the language parameter" do
    create_common_names
    @request.headers["X-Authentication-Token"] = @user.authentication_token
    get :index, params: { name: @taxon_concept.full_name, language: 'PL,IT' }
    results = JSON.parse(response.body)
    taxon_concept = results['taxon_concepts'].first
    common_names = taxon_concept['common_names']
    assert_equal 'PL', common_names.first["language"]
    assert_equal 'IT', common_names.last["language"]
    assert_equal 2, common_names.length
  end

  test "it records a request with params" do
    FactoryBot.create(:taxon_concept, taxonomy: @cites, updated_at: 1.year.ago)
    FactoryBot.create(:taxon_concept, taxonomy: @cites, updated_at: 1.month.ago)
    @request.headers["X-Authentication-Token"] = @user.authentication_token

    assert_difference 'ApiRequest.count' do
      get :index, params: { updated_since: 2.months.ago.to_s }
    end

    assert_not_nil ApiRequest.last.params
  end

  test "it records an unauthorised request" do
    assert_difference 'ApiRequest.count' do
      get :index
    end

    assert_equal 401, ApiRequest.last.response_status
  end

  test 'it returns an unprocessable entity response when taxonomy is not cms or cites' do
    @request.headers["X-Authentication-Token"] = @user.authentication_token
    assert_difference 'ApiRequest.count' do
      get :index, params: { taxonomy: 'something' }
    end
    assert_response 422
  end

  test 'it returns an unprocessable entity response when with_descendants is specified without name' do
    @request.headers["X-Authentication-Token"] = @user.authentication_token
    assert_difference 'ApiRequest.count' do
      get :index, params: { with_descendants: 'true' }
    end
    assert_response 422
  end

  test 'it returns an unprocessable entity response when unpermitted parameters are specified' do
    @request.headers["X-Authentication-Token"] = @user.authentication_token
    assert_difference 'ApiRequest.count' do
      get :index, params: { aparam: 'something' }
    end
    assert_response 422
  end

  test 'it returns a bad request error when incorrectly formatted data' do
    @request.headers["X-Authentication-Token"] = @user.authentication_token
    get :index, params: { updated_since: '2012-122-12' }
    assert_response 400
  end

  test 'it returns a bad request error when incorrect page value' do
    @request.headers["X-Authentication-Token"] = @user.authentication_token
    assert_difference 'ApiRequest.count' do
      get :index, params: { page: 'something' }
    end
    assert_response 400
  end

  # test "it records a failed request" do
  #   @request.headers["X-Authentication-Token"] = @user.authentication_token

  #   assert_difference 'ApiRequest.count' do
  #     get :index, params: { updated_since: '33' }
  #   end

  #   assert_equal 500, ApiRequest.last.response_status
  # end

end
