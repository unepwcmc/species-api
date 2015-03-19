class Api::V1::TaxonConceptsController < Api::V1::BaseController
  after_action only: [:index] { set_pagination_headers(:taxon_concepts) }
  before_action :validate_params, only: [:index]

  resource_description do
    formats ['JSON', 'XML']
    api_base_url 'api/v1/taxon_concepts'
    name 'Taxon Concepts'
  end

  api :GET, '/', 'Lists taxon concepts'

  description <<-EOS
  The following taxon concept fields are returned:
  [id] unique identifier of a taxon concept
  [full_name] scientific name
  [author_year] author and year (parentheses where applicable)
  [rank] one of KINGDOM, PHYLUM, CLASS, ORDER, FAMILY, SUBFAMILY, GENUS, SPECIES, SUBSPECIES, VARIETY
  [name_status] A for accepted names, S for synonyms (both types of names are taxon concepts in Species+)
  [updated_at] timestamp of last update to the taxon concept in Species+
  [cites_listing] value of current CITES listing (as per CITES Checklist). When taxon concept is removed from appendices this becomes 'NC'. When taxon is split listed it becomes a concatenation of appendix symbols, e.g. 'I/II/NC'
  [higher_taxa] object that gives scientific names of ancestors in the taxonomic tree
  [synonyms] list of synonyms
  [common names] list of common names (with language given by ISO 639-1 code)
  [cites_listings] list of current CITES listings with annotations (there will be more than one element in this list in case of split listings)
  EOS

  param :page, String, desc: 'Page number for paginated responses', required: false
  param :per_page, String, desc: 'Limit for how many objects returned per page for paginated responses. If not specificed it will default to the maximum value of 500', required: false
  param :updated_since, String, desc: 'Pull only objects updated after (and including) the specified timestamp in ISO8601 format (UTC time).', required: false
  param :name, String, desc: 'Filter taxon concepts by name', required: false
  param :with_descendants, String, desc: 'Broadens the above search by name to include higher taxa. Value must be true or false', required: false
  param :taxonomy, String, desc: 'Filter taxon concepts by taxonomy, accepts either CITES or CMS as its value. Defaults to CITES if no value is specified', required: false
  param :language, String, desc: 'Filter languages returned for common names. Value should be a single country code or a comma separated string of country codes (e.g. language=EN,PL,IT). Defaults to showing all available languages if no language parameter is specified', required: false

  example <<-EOS
  {
    "pagination":{
      "current_page":1,
      "per_page":500,
      "total_entries":1
    },
    "taxon_concepts":[
      {
        "id":4521,
        "full_name":"Loxodonta africana",
        "author_year":"(Blumenbach, 1797)",
        "rank":"SPECIES",
        "name_status":"A",
        "updated_at":"2014-12-11T15:39:51.620Z",
        "cites_listing":"I/II",
        "higher_taxa":{
          "kingdom":"Animalia",
          "phylum":"Chordata",
          "class":"Mammalia",
          "order":"Proboscidea",
          "family":"Elephantidae"
        },
        "synonyms":[
          {
            "id":37069,
            "full_name":"Loxodonta cyclotis",
            "author_year":"(Matschie, 1900)",
            "rank":"SPECIES"
          }
        ],
        "common_names":[
          {
            "name":"African Elephant",
            "language":"EN"
          },
          {
            "name":"African Savannah Elephant",
            "language":"EN"
          },
          {
            "name":"Eléphant d'Afrique",
            "language":"FR"
          },
          {
            "name":"Eléphant africain",
            "language":"FR"
          }
        ],
        "cites_listings":[
          {
            "appendix":"II",
            "annotation":"The populations of Botswana, Namibia, South Africa and Zimbabwe are listed in Appendix II for the exclusive purpose of allowing: [...]",
            "hash_annotation":null
          },
          {
            "appendix":"I",
            "annotation":"Included in Appendix I, except the populations of Botswana, Namibia, South Africa and Zimbabwe, which are included in Appendix II.",
            "hash_annotation":null
          }
        ]
      }
    ]
  }
  EOS

  example <<-EOS
  <?xml version="1.0" encoding="UTF-8"?>
  <hash>
    <pagination>
      <current-page type="integer">1</current-page>
      <per-page type="integer">500</per-page>
      <total-entries type="integer">1</total-entries>
    </pagination>
    <taxon-concepts type="array">
      <taxon-concept>
        <id type="integer">4521</id>
        <full-name>Loxodonta africana</full-name>
        <author-year>(Blumenbach, 1797)</author-year>
        <rank>SPECIES</rank>
        <name-status>A</name-status>
        <updated-at type="dateTime">2014-12-11T15:39:51Z</updated-at>
        <cites-listing>I/II</cites-listing>
        <higher-taxa>
          <kingdom>Animalia</kingdom>
          <phylum>Chordata</phylum>
          <class>Mammalia</class>
          <order>Proboscidea</order>
          <family>Elephantidae</family>
        </higher-taxa>
        <synonyms type="array">
          <synonym>
            <id type="integer">37069</id>
            <full-name>Loxodonta cyclotis</full-name>
            <author-year>(Matschie, 1900)</author-year>
            <rank>SPECIES</rank>
          </synonym>
        </synonyms>
        <common-names type="array">
          <common-name>
            <name>African Elephant</name>
            <language>EN</language>
          </common-name>s
          <common-name>
            <name>African Savannah Elephant</name>
            <language>EN</language>
          </common-name>
          <common-name>
            <name>Eléphant d'Afrique</name>
            <language>FR</language>
          </common-name>
          <common-name>
            <name>Eléphant africain</name>
            <language>FR</language>
          </common-name>
        </common-names>
        <cites-listings type="array">
          <cites-listing>
            <appendix>II</appendix>
            <annotation>The populations of Botswana, Namibia, South Africa and Zimbabwe are listed in Appendix II for the exclusive purpose of allowing: [...]</annotation>
            <hash-annotation nil="true"/>
          </cites-listing>
          <cites-listing>
            <appendix>I</appendix>
            <annotation>Included in Appendix I, except the populations of Botswana, Namibia, South Africa and Zimbabwe, which are included in Appendix II.</annotation>
            <hash-annotation nil="true"/>
          </cites-listing>
        </cites-listings>
      </taxon-concept>
    </taxon-concepts>
  </hash>
  EOS

  def index
    taxon_per_page = TaxonConcept.per_page
    new_per_page = params[:per_page] && params[:per_page].to_i < taxon_per_page ? params[:per_page] : taxon_per_page
    @taxon_concepts = TaxonConcept.
      paginate(
        page: params[:page],
        per_page: new_per_page
      ).order(:taxonomic_position)

    if params[:with_descendants] == "true" && params[:name]
      @taxon_concepts = @taxon_concepts.where("lower(full_name) = :name
                                              OR lower(genus_name) = :name
                                              OR lower(family_name) = :name
                                              OR lower(order_name) = :name
                                              OR lower(class_name) = :name
                                              OR lower(phylum_name) = :name
                                              OR lower(kingdom_name) = :name
                                              ", name: params[:name].downcase)
    elsif params[:name]
      @taxon_concepts = @taxon_concepts.where("lower(full_name) = ?", params[:name].downcase)
    end

    if params[:updated_since]
      @taxon_concepts = @taxon_concepts.where("updated_at >= ?", params[:updated_since])
    end

    taxonomy_is_cites_eu = if params[:taxonomy]
      case params[:taxonomy].downcase
        when 'cms'
          false
        else
          true
        end
    else
      true
    end

    @taxon_concepts = @taxon_concepts.where(taxonomy_is_cites_eu: taxonomy_is_cites_eu)

    render 'api/v1/taxon_concepts/index'
  end

  #overrides method from parent controller
  def set_language
    language = params[:language] ? params[:language].try(:downcase).split(',').first.delete(' ').try(:to_sym) ||
      :en : :en
    I18n.locale = if [:en, :es, :fr].include?(language)
      language
    else
      I18n.default_locale
    end
    @languages = params[:language].delete(' ').split(',').map! { |lang| lang.upcase } unless params[:language].nil?
  end

  def permit_params
    params.permit(
      :page, :per_page, :updated_since, :name,
      :with_descendants, :taxonomy, :language, :format
    )
  end

  def validate_params
    @message = ''
    code = 400

    if params[:updated_since]
      y, m, d = params[:updated_since].split('-')
      @message = "Invalid date format" unless Date.valid_date? y.to_i, m.to_i, d.to_i
    elsif params[:page]
      @message = "Invalid page format" unless /\A\d+\Z/.match(params[:page])
    elsif params[:per_page]
      @message = "Invalid per_page format" unless /\A\d+\Z/.match(params[:per_page])
    elsif (params[:taxonomy].present? && !(/cms|cites/.match(params[:taxonomy].downcase)))
      @message = "Invalid taxonomy"
      code = 422
    elsif (params[:with_descendants] == 'true' && !params[:name].present?)
      @message = "Invalid use of with_descendants"
      code = 422
    end

    if @message.present?
      create_api_request(@message, code)
      render 'api/error', status: code
    end
  end
end
