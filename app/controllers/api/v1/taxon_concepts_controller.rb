class Api::V1::TaxonConceptsController < Api::V1::BaseController
  after_action only: [:index] do
    set_pagination_headers(:taxon_concepts)
  end

  before_action :validate_params, :set_eu_listings_display, only: [:index]

  resource_description do
    formats ['JSON', 'XML']
    api_base_url 'api/v1/taxon_concepts'
    name 'Taxon Concepts'
  end

  api :GET, '/', 'Lists taxon concepts'

  description <<-EOS
The following taxon concept fields are returned:

[id] unique identifier of a taxon concept
[full_name] scientific name [max 255 characters]
[author_year] author and year (parentheses where applicable) [max 255 characters]
[rank] one of +KINGDOM+, +PHYLUM+, +CLASS+, +ORDER+, +FAMILY+, +SUBFAMILY+, +GENUS+, +SPECIES+, +SUBSPECIES+, +VARIETY+ [max 255 characters]
[name_status] +A+ for accepted names, +S+ for synonyms (both types of names are taxon concepts in Species+) [max 255 characters]
[updated_at] timestamp of last update to the taxon concept in Species+
[active] if false, taxon concept has been deleted
[synonyms] list of synonyms (only for accepted names, i.e. name_status == A) [full_name, author_year and rank follow the same length constraints as respective properties of the main taxon concept]
[higher_taxa] object that gives scientific names of ancestors in the taxonomic tree (only for active accepted names) [higher taxa names follow the same length constraint as full_name of the main taxon concept]
[common_names] list of common names (with language given by ISO 639-1 code; only for accepted names) [name, language max 255 characters]
[cites_listing] value of current CITES listing (as per CITES Checklist). When taxon concept is removed from appendices this becomes +NC+. When taxon is split listed it becomes a concatenation of appendix symbols, e.g. +I/II/NC+ (only for accepted names) [max 255 characters]
[cites_listings] list of current CITES listings with annotations (there will be more than one element in this list in case of split listings; only for accepted names) [appendix max 255 characters; annotation, hash_annotation unlimited length]
[eu_listing] value of current EU listing. When taxon concept is removed from annexes this becomes +NC+. When taxon is split listed it becomes a concatenation of annex symbols, e.g. +A/B/NC+ (only for accepted names) [max 255 characters]
[eu_listings] list of current EU listings with annotations (there will be more than one element in this list in case of split listings; only for accepted names) [appendix max 255 characters; annotation, hash_annotation unlimited length]
[accepted_names] list of accepted names (only for synonyms, i.e. name_status == S) [full_name, author_year and rank follow the same length constraints as respective properties of the main taxon concept]

==== Note on deleted taxon concepts

In the event of removal from CITES appendices, a taxon is not deleted from the Species+ DB. As a historically listed taxon it remains in the database, and in most cases the value of current CITES listing becomes 'NC'. In some cases the value is affected by listed subspecies, e.g. <i>Pseudomys fieldi</i> has been removed from Appendix I, but since there is a listed subspecies, the current listing is 'I/NC'.

Taxon concepts are deleted from the Species+ database only on rare occasions when they have been entered by mistake. API consumers can detect this event by checking the value of the 'active' flag, which is set to false in case of deleted taxa.

==== Note on +updated_since+

The +updated_since+ parameter is intended to be used in order to allow API clients to only fetch taxon concepts updated since the last run of the synchronisation job. Those taxa will include:
- Taxa that have been newly added. This can be verified by checking against the list of existing identifiers.
- Taxa that have been deleted. This can be inferred by the value of the active flag.
- Taxa that have been updated, and that includes changes to the taxon concept record as well as linked records (names, distribution, references, CITES or EU legislation). There is no way to infer which piece of information was changed and in such cases a full re-synchronisation of all infomation on that taxon concept is recommended.

==== Note on pagination

Where more than 500 taxon concepts are returned, the request is paginated, showing 500 objects (or less by passing in an optional 'per_page' parameter) at a time. To fetch the remaining objects, you will need to make a new request and pass the optional ‘page’ parameter as below:

  https://api.speciesplus.net/api/v1/taxon_concepts?page=2&per_page=25

Information about the remaining pages is provided in the Link header of the API response. For example, making the above request for page two, with a limit of 25 objects per page would return the following in the link header along with a total-count header:

  Link: <https://api.speciesplus.net/api/v1/taxon_concepts?page=3&per_page=25>; rel="next", <https://api.speciesplus.net/api/v1/taxon_concepts?page=2570&per_page=25>; rel="last"
  Total-Count: 64230

If there are additional pages, the link header will contain the URL for the next page of results, followed by the URL for the last page of results. The Total-Count header shows the total number of objects returned for this call, regardless of pagination.

For convenience, a 'pagination' meta object is also included in the body of the response.
  EOS

  param :page, String, desc: 'Page number for paginated responses', required: false
  param :per_page, String, desc: 'Limit for how many objects returned per page for paginated responses. If not specificed it will default to the maximum value of 500', required: false
  param :updated_since, String, desc: 'Pull only objects updated after (and including) the specified timestamp in ISO8601 format (UTC time).', required: false
  param :name, String, desc: 'Filter taxon concepts by name', required: false
  param :with_descendants, String, desc: 'Broadens the above search by name to include higher taxa. Value must be true or false', required: false
  param :taxonomy, String, desc: 'Filter taxon concepts by taxonomy, accepts either CITES or CMS as its value. Defaults to CITES if no value is specified', required: false
  param :language, String, desc: 'Filter languages returned for common names. Value should be a single country code or a comma separated string of country codes (e.g. language=EN,PL,IT). Defaults to showing all available languages if no language parameter is specified', required: false
  param :with_eu_listings, String, desc: 'Include EU listing data. Value must be true or false, defaults to false', required: false

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
        "active":true,
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
        ],
        "eu_listings":[
          {
            "id":"32796"
            "annex":"A"
            "annotation":"Except for the populations of Botswana, Namibia, South Africa and Zimbabwe, which are included in Annex B."
            "hash_annotation":nil
            "effective_at":"2022-01-19"
            "party":nil
          },
          {
            "id":"34129"
            "annex":"B"
            "annotation":"Only the populations of Botswana, Namibia, South Africa and Zimbabwe; all other populations are included in Annex A. [...]"
            "hash_annotation":nil
            "effective_at":"2022-01-19"
            "party":nil
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
        <active type="boolean">true</active>
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
        <eu-listings>
          <eu-listing>
            <id type="integer">32796</id>
            <annex>A</annex>
            <annotation>Except for the populations of Botswana, Namibia, South Africa and Zimbabwe, which are [...]</annotation>
            <hash-annotation inl="true"/>
            <effective-at>2022-01-19</effective-at>
            <party nil="true"/>
          </eu-listing>
          <eu-listing>
            <id type="integer">34129</id>
            <annex>B</annex>
            <annotation>Only the populations of Botswana, Namibia, South Africa and Zimbabwe; all other populations are [...]</annotation>
            <hash-annotation inl="true"/>
            <effective-at>2022-01-19</effective-at>
            <party nil="true"/>
          </eu-listing>
        </eu-listings>
      </taxon-concept>
    </taxon-concepts>
  </hash>
  EOS

  error code: 400, desc: "Bad Request"
  error code: 401, desc: "Unauthorized"
  error code: 404, desc: "Not Found"
  error code: 422, desc: "Unprocessable Entity"
  error code: 500, desc: "Internal Server Error"

  def index
    taxon_per_page = TaxonConcept.per_page
    new_per_page =
      if params[:per_page] && params[:per_page].to_i < taxon_per_page
        params[:per_page]
      else
        taxon_per_page
      end

    taxon_concepts_cached, total_entries =
      Rails.cache.fetch(cache_key, expires_in: 1.month) do
        taxon_concepts = taxon_concepts_query(
          TaxonConcept.paginate(
            page: params[:page],
            per_page: new_per_page
          ).order(:taxonomic_position),
          params
        )

        total_entries = taxon_concepts.total_entries

        taxon_concepts_json =
          taxon_concepts.map do |tc|
            tc_json = tc.as_json
            tc_json['common_names_list'] =
              tc.common_names_with_iso_code(@languages).as_json
            tc_json['cites_listings_list'] =
              tc.current_cites_additions.as_json
            tc_json
          end

        [
          taxon_concepts_json,
          taxon_concepts.total_entries,
        ]
      end

    @taxon_concepts =
      WillPaginate::Collection.create(
        params[:page] || 1, new_per_page, total_entries
      ) do |pager|
        pager.replace(
          TaxonConcept.hydrate(taxon_concepts_cached)
        )
      end

    render 'api/v1/taxon_concepts/index'
  end

  def taxon_concepts_query(rel, params)
    taxon_concepts =
      rel.select([
        :id, :full_name, :author_year, :name_status, :rank, :cites_listing,
        :higher_taxa, :synonyms, :accepted_names, :updated_at, :active
      ])

    if params[:with_descendants] == "true" && params[:name]
      taxon_concepts =
        taxon_concepts.where(
          (
            <<-SQL.squish
              upper(full_name) = :name
              OR upper(genus_name) = :name
              OR upper(family_name) = :name
              OR upper(order_name) = :name
              OR upper(class_name) = :name
              OR upper(phylum_name) = :name
              OR upper(kingdom_name) = :name
            SQL
          ),
          name: params[:name].upcase
        )
    elsif params[:name]
      taxon_concepts =
        taxon_concepts.where("upper(full_name) = ?", params[:name].upcase)
    end

    if params[:updated_since]
      taxon_concepts =
        taxon_concepts.where("updated_at >= ?", params[:updated_since])
    end

    taxonomy_is_cites_eu =
      if params[:taxonomy] && params[:taxonomy].downcase == 'cms'
        false
      else
        true
      end

    taxon_concepts =
      taxon_concepts.where(taxonomy_is_cites_eu: taxonomy_is_cites_eu)

    taxon_concepts = taxon_concepts.includes(
      :current_cites_additions,
      :common_names
    )

    taxon_concepts = taxon_concepts.includes(
      :current_eu_additions,
    ) if 'true' == params[:with_eu_listings] && taxonomy_is_cites_eu

    taxon_concepts
  end

  private

  #overrides method from parent controller
  def set_language
    language =
      if params[:language]
        params[:language].try(:downcase).split(',').first.delete(' ') || 'en'
      else
        'en'
      end

    I18n.locale =
      if ['en', 'es', 'fr'].include?(language)
        language
      else
        I18n.default_locale
      end

    @languages =
      params[:language].delete(' ').split(',').map!(&:upcase) unless (
        params[:language].nil?
      )
  end

  def set_eu_listings_display
    @eu_listings = params[:with_eu_listings]
  end

  def permitted_params
    [
      :page, :per_page, :updated_since, :name,
      :with_descendants, :taxonomy, :language, :format, :with_eu_listings
    ]
  end

  def validate_params
    super()
    [
      :updated_since,
      :page,
      :per_page,
      :with_descendants,
      :with_eu_listings
    ].each do |param|
      unless send(:"validate_#{param}_format")
        raise Api::PaginationError, "Invalid parameter format: #{param}"
      end
    end

    if (
      params[:taxonomy].present? && !(
        /^(cms|cites)$/.match(params[:taxonomy].downcase)
      )
    )
      raise Api::ValidationError, "Unknown taxonomy: #{params[:taxonomy]}"
    end

    if (params[:with_descendants] == 'true' && params[:name].blank?)
      raise Api::ValidationError, "Invalid use of with_descendants"
    end
  end

  def validate_updated_since_format
    return true unless params[:updated_since]

    y, m, d = params[:updated_since].split('-')

    Date.valid_date? y.to_i, m.to_i, d.to_i
  end

  def is_positive_integer?(val)
    /\A\d+\Z/.match?(val) && val.to_i <= 2147483647
  end

  def is_boolean?(val)
    /\A(true|false)\Z/.match?(val)
  end

  def validate_page_format
    return true unless params[:page]

    is_positive_integer?(params[:page])
  end

  def validate_per_page_format
    return true unless params[:per_page]

    is_positive_integer?(params[:per_page])
  end

  def validate_with_descendants_format
    return true unless params[:with_descendants]

    is_boolean?(params[:with_descendants])
  end

  def validate_with_eu_listings_format
    return true unless params[:with_eu_listings]

    is_boolean?(params[:with_eu_listings])
  end
end
