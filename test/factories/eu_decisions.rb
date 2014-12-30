Dir[Rails.root.join("test/support/models/*.rb")].each {|f| require f}
FactoryGirl.define do
  factory :eu_decision, class: Test::EuDecision do
    taxon_concept
    geo_entity
    eu_decision_type

    factory :eu_opinion, class: Test::EuOpinion do
      start_date Date.new(2013,1,1)
    end

    factory :eu_suspension, class: Test::EuSuspension
  end

  factory :eu_decision_type, class: Test::EuDecisionType do
    sequence(:name) {|n| "Opinion#{n}"}
    decision_type "NO_OPINION"
  end
end
