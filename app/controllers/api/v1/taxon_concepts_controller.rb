class Api::V1::TaxonConceptsController < Api::V1::BaseController
  resource_description do
    formats ['JSON', 'XML']
    api_base_url 'api/v1/taxon_concepts'
    name 'Taxon Concepts'
  end

  api :GET, '/', 'Lists taxon concepts'
  param :page, String, desc: 'Page Number', required: false
  param :updated_since, Time, desc: 'Return taxa updated since', required: false
  example <<-EOS
    [
      {
        "taxon_concept":{
          "id":4521,
          "full_name":"Loxodonta africana",
          "author_year":"(Blumenbach, 1797)",
          "rank_name":"SPECIES",
          "name_status":"A",
          "updated_at":"2014-10-14T08:55:39.212Z",
          "higher_taxa":{
            "kingdom":"Animalia",
            "phylum":"Chordata",
            "class":"Mammalia",
            "order":"Proboscidea",
            "family":"Elephantidae"
          },
          "synonyms":null
        }
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
        <rank-name>SPECIES</rank-name>
        <name-status>A</name-status>
        <updated-at type="dateTime">2014-10-14T08:55:39Z</updated-at>
        <higher-taxa>
          <kingdom>Animalia</kingdom>
          <phylum>Chordata</phylum>
          <class>Mammalia</class>
          <order>Proboscidea</order>
          <family>Elephantidae</family>
        </higher-taxa>
        <synonyms nil="true"/>
      </taxon-concept>
    </taxon-concepts>
  EOS

  def index
    @taxon_concepts = TaxonConcept.
      where(
        rank_name: 'SPECIES',
        taxonomy_is_cites_eu: true,
        name_status: 'A',
        full_name: 'Loxodonta africana'
      ).paginate(:page => params[:page]).order('full_name')
    render 'api/v1/taxon_concepts/index'
  end
end
