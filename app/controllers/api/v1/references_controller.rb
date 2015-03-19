class Api::V1::ReferencesController < Api::V1::BaseController
  resource_description do
    formats ['JSON', 'XML']
    api_base_url 'api/v1/taxon_concepts'
  end

  api :GET, '/:taxon_concept_id/references', 'Lists references for a given taxon concept'
  param :taxon_concept_id, String, :desc => "Taxon Concept ID", :required => true
  example <<-EOS
  [
    {
      "citation":"Wilson, D.E. and Reeder, D.M. (Eds.) 1993. <i>Mammal species of the world, a taxonomic and geographic reference</i>. Smithsonian Institution Press. Washington and London.",
      "is_standard":true
    },
    {
      "citation":"Wilson, D.E. and Reeder, D.M. (Eds.) 2005. <i>Mammal species of the world, a taxonomic and geographic reference</i>. The Johns Hopkins University Press.",
      "is_standard":false
    }
  ]
  EOS

  example <<-EOS
  <?xml version="1.0" encoding="UTF-8"?>
  <taxon-references type="array">
    <taxon-reference>
      <citation>Wilson, D.E. and Reeder, D.M. (Eds.) 1993. &lt;i&gt;Mammal species of the world, a taxonomic and geographic reference&lt;/i&gt;. Smithsonian Institution Press. Washington and London.</citation>
      <is-standard type="boolean">true</is-standard>
    </taxon-reference>
    <taxon-reference>
      <citation>Wilson, D.E. and Reeder, D.M. (Eds.) 2005. &lt;i&gt;Mammal species of the world, a taxonomic and geographic reference&lt;/i&gt;. The Johns Hopkins University Press.</citation>
      <is-standard type="boolean">false</is-standard>
    </taxon-reference>
  </taxon-references>
  EOS

  def index
    @references = TaxonConcept.find(params[:taxon_concept_id]).
      taxon_references.order(:citation)
  end

  def permit_params_child
    params.permit(:taxon_concept_id, :format)
  end
end
