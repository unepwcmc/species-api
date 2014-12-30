Dir[Rails.root.join("test/support/models/*.rb")].each {|f| require f}
FactoryGirl.define do
  factory :event, class: Test::Event do
    sequence(:name) {|n| "CoP#{n}"}
    effective_at '2014-12-01'
    factory :eu_regulation, :class => Test::EuRegulation do
      type 'EuRegulation'
      end_date '2014-12-01'
    end
    factory :eu_suspension_regulation, :class => Test::EuSuspensionRegulation do
      type 'EuSuspensionRegulation'
    end
    factory :cites_suspension_notification, :class => Test::CitesSuspensionNotification,
      :aliases => [:start_notification] do
      type 'CitesSuspensionNotification'
      end_date '2012-01-01'
    end
  end
end
