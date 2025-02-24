node(:cites_listings) do |tc|
  tc.cites_listings.map do |cl|
    partial('api/v1/cites_legislation/cites_listing', :object => cl)
  end
end

node(:cites_quotas) do |tc|
  tc.cites_quotas_including_global.map do |cites_quota|
    partial('api/v1/cites_legislation/cites_quota', :object => cites_quota)
  end
end

node(:cites_suspensions) do |tc|
  tc.cites_suspensions_including_global.map do |cites_suspension|
    partial('api/v1/cites_legislation/cites_suspension', :object => cites_suspension)
  end
end

node(:eu_listings) do |tc|
  tc.eu_listings.map do |el|
    partial('api/v1/eu_legislation/eu_listing', :object => el)
  end
end

node(:eu_decisions) do |tc|
  tc.eu_decisions.map do |eu_decision|
    partial('api/v1/eu_legislation/eu_decision', :object => eu_decision)
  end
end

node(:distributions) do |tc|
  tc.distributions.map do |distribution|
    partial('api/v1/distributions/record', :object => distribution)
  end
end

node(:references) do |tc|
  tc.taxon_references.map do |reference|
    partial('api/v1/references/record', :object => reference)
  end
end
