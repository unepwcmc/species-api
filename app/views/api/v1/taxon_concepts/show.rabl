object @taxon_concept

node do |taxon_concept|
  partial('api/v1/taxon_concepts/record', object: taxon_concept)
end