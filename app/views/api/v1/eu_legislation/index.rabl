object @taxon_concept => :eu_legislation
cache [:eu_legislation, @taxon_concept]

child @eu_listings => :eu_listings do
  node do |eu_listing|
    partial('api/v1/eu_legislation/eu_listing', object: eu_listing)
  end
end

child @eu_decisions => :eu_decisions do
  node do |eu_decision|
    partial('api/v1/eu_legislation/eu_decision', object: eu_decision)
  end
end
