class Api::V1::TaxonConceptsController < Api::V1::BaseController
  after_action only: [:index] { set_pagination_headers(:taxon_concepts) }

  resource_description do
    formats ['JSON', 'XML']
    api_base_url 'api/v1/taxon_concepts'
    name 'Taxon Concepts'
  end

  api :GET, '/', 'Lists taxon concepts'
  param :page, String, desc: 'Page number for paginated responses', required: false
  param :per_page, String, desc: 'Limit for how many objects returned per page for paginated responses. If not specificed it will default to the maximum value of 100', required: false
  param :updated_since, String, desc: 'Pull only objects updated after (and including) the specified timestamp in ISO8601 format (UTC time).', required: false
  param :name, String, desc: 'Filter taxon concepts by name', required: false
  param :with_descendants, String, desc: 'Broadens the above search by name to include higher taxa. Value must be true or false', required: false
  param :taxonomy, String, desc: 'Filter taxon concepts by taxonomy, accepts either CITES or CMS as its value. Defaults to CITES if no value is specified', required: false

  example <<-EOS
  [
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
  EOS

  example <<-EOS
  <?xml version="1.0" encoding="UTF-8"?>
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
        </common-name>
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
      @taxon_concepts = @taxon_concepts.where("full_name = :name
                                              OR genus_name = :name
                                              OR family_name = :name
                                              OR order_name = :name
                                              OR class_name = :name
                                              OR phylum_name = :name
                                              OR kingdom_name = :name
                                              ", name: params[:name])
    elsif params[:name]
      @taxon_concepts = @taxon_concepts.where(full_name: params[:name])
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
end
