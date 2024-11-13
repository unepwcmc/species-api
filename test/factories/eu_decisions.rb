Dir[Rails.root.join("test/support/models/*.rb")].each {|f| require f}

FactoryGirl.define do
  factory :eu_decision, class: Test::EuDecision do
    association :taxon_concept
    association :geo_entity
    association :eu_decision_type

    factory :eu_opinion, class: Test::EuOpinion do
      type { 'EuOpinion' }
      start_date { Date.new(2013,1,1) }
    end

    factory :eu_suspension, class: Test::EuSuspension do
      type { 'EuSuspension' }
      association :start_event
      association :end_event
    end
  end

  factory :eu_decision_type, class: Test::EuDecisionType do
    sequence(:name) {|n| "Opinion#{n}"}
    decision_type { 'NO_OPINION' }
  end
end
