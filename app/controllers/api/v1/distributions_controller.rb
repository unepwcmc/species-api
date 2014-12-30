class Api::V1::DistributionsController < Api::V1::BaseController
  resource_description do
    formats ['JSON', 'XML']
    api_base_url 'api/v1/taxon_concepts'
  end

  api :GET, '/:taxon_concept_id/distributions', 'Lists distributions for a given taxon concept'
  param :taxon_concept_id, String, desc: 'Taxon Concept ID', required: true
  param :language, String, desc: 'Select language for the names of distributions. Select en, fr, or es. Defaults to en.', required: false

  example <<-EOS
    [
      {
        "distribution": {
          "iso_code2" : "NI",
          "tags" : [],
          "type" : "COUNTRY",
          "references" : [
            "Howell, T.R. 2010. Thomas R. Howell's check-list of the birds of Nicaragua as of 1993. Ornithological Monographs: 68: 1-108.",
            "Martínez-Sánchez, J. C. 2007. Lista patrón de las aves de Nicaragua; Con información de nuevos registros, distribución y localidades donde observar aves. Alianza para las Areas Silvestres. Granada, Nicaragua.",
            "Ridgely, R. S. and Gwynne, J. A. 1989. A guide to the birds of Panama with Costa Rica, Nicaragua, and Honduras. 2nd edition. Princeton University Press. Princeton, New Jersey."  
          ],
          "name" : "Nicaragua"
        }
      }
    ]
  EOS

  example <<-EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <distributions type="array">
      <distribution>
        <name>Nicaragua</name>
        <iso-code2>NI</iso-code2>
        <tags type="array"/>
        <type>COUNTRY</type>
        <references type="array">
          <reference>Howell, T.R. 2010. Thomas R. Howell's check-list of the birds of Nicaragua as of 1993. Ornithological Monographs: 68: 1-108.</reference>
          <reference>Martínez-Sánchez, J. C. 2007. Lista patrón de las aves de Nicaragua; Con información de nuevos registros, distribución y localidades donde observar aves. Alianza para las Areas Silvestres. Granada, Nicaragua.</reference>
          <reference>Ridgely, R. S. and Gwynne, J. A. 1989. A guide to the birds of Panama with Costa Rica, Nicaragua, and Honduras. 2nd edition. Princeton University Press. Princeton, New Jersey.</reference>
        </references>
      </distribution>
    </distributions>
  EOS

  def index
    @distributions = TaxonConcept.find(params[:taxon_concept_id]).distributions
  end
end
