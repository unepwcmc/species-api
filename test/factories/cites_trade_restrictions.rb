Dir[Rails.root.join("test/support/models/*.rb")].each {|f| require f}
FactoryGirl.define do
  factory :trade_restriction, class: Test::TradeRestriction do
    geo_entity
    is_current true

    factory :cites_suspension, class: Test::CitesSuspension do
      start_notification
      type 'CitesSuspension'
    end

    factory :quota, class: Test::Quota do
      unit
      publication_date Date.new(2012, 12, 3)
      quota '10'
      type 'Quota'
    end
  end
end