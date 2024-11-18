Dir[Rails.root.join("test/support/models/*.rb")].each {|f| require f}

FactoryBot.define do
  factory :trade_restriction, class: Test::TradeRestriction do
    association :geo_entity
    association :start_notification
    association :end_notification
    is_current { true }

    factory :cites_suspension, class: Test::CitesSuspension do
      type { 'CitesSuspension' }
    end

    factory :quota, class: Test::Quota do
      association :unit
      publication_date { Date.new(2012, 12, 3) }
      quota { '10' }
      type { 'Quota' }
    end
  end
end