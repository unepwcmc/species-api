class Api::V1::DistributionsController < Api::V1::BaseController
  resource_description do
    formats ['JSON', 'XML']
    api_base_url 'api/v1/taxon_concepts'
  end

  api :GET, '/:taxon_concept_id/distributions', 'Lists distributions for a given taxon concept'

  description <<-EOS
[iso_code2] ISO 3166-1 alpha-2
[name] name of country / territory (translated based on locale)
[type] one of <tt>COUNTRY</tt> or <tt>TERRITORY</tt>
[tags] array of distribution tags, e.g. <tt>extinct</tt> (strings)
[references] array of citations (strings)
  EOS

  param :taxon_concept_id, String, desc: 'Taxon Concept ID', required: true
  param :language, String, desc: 'Select language for the names of distributions. Select en, fr, or es. Defaults to en.', required: false

  example <<-EOS
  [
    {
      "iso_code2":"GQ",
      "name":"Equatorial Guinea",
      "tags":[

      ],
      "type":"COUNTRY",
      "references":[
        "Basilio, A. 1962. La vida animal en la Guinea Espanola. Instituto de Estudios Africanos. Madrid."
      ]
    },
    {
      "iso_code2":"MR",
      "name":"Mauritania",
      "tags":[
        "extinct"
      ],
      "type":"COUNTRY",
      "references":[
        "Blanc, J.J., Thouless, C.R., Hart, J.A., Dublin H.T., Douglas-Hamilton, I., Craig, C.R. and Barnes, R.F.W. 2003. African Elephant Status Report 2002: an update from the African Elephant Database. http://iucn.org/afesg/aed/aesr2002.html IUCN/SSC African Elephant Specialist Group. IUCN, Gland, Switzerland and Cambridge, UK. ",
        "Jackson, P. 1982. Elephants and rhinos in Africa. A time for decision. IUCN. Gland."
      ]
    }
  ]
  EOS

  example <<-EOS
  <?xml version="1.0" encoding="UTF-8"?>
  <distributions type="array">
    <distribution>
      <iso-code2>GQ</iso-code2>
      <name>Equatorial Guinea</name>
      <tags type="array"/>
      <type>COUNTRY</type>
      <references type="array">
        <reference>Basilio, A. 1962. La vida animal en la Guinea Espanola. Instituto de Estudios Africanos. Madrid.</reference>
      </references>
    </distribution>
    <distribution>
      <iso-code2>MR</iso-code2>
      <name>Mauritania</name>
      <tags type="array">
        <tag>extinct</tag>
      </tags>
      <type>COUNTRY</type>
      <references type="array">
        <reference>Blanc, J.J., Thouless, C.R., Hart, J.A., Dublin H.T., Douglas-Hamilton, I., Craig, C.R. and Barnes, R.F.W. 2003. African Elephant Status Report 2002: an update from the African Elephant Database. http://iucn.org/afesg/aed/aesr2002.html IUCN/SSC African Elephant Specialist Group. IUCN, Gland, Switzerland and Cambridge, UK. </reference>
        <reference>Jackson, P. 1982. Elephants and rhinos in Africa. A time for decision. IUCN. Gland.</reference>
      </references>
    </distribution>
  </distributions>
  EOS

  error code: 400, desc: "Bad Request"
  error code: 401, desc: "Unauthorized"
  error code: 404, desc: "Not Found"
  error code: 422, desc: "Unprocessable Entity"
  error code: 500, desc: "Internal Server Error"

  def index
    @distributions = TaxonConcept.find(params[:taxon_concept_id]).distributions
  end

  def permitted_params
    [:taxon_concept_id, :language, :format]
  end
end
