Dir[Rails.root.join("test/support/models/*.rb")].each {|f| require f}

FactoryBot.define do
  factory :trade_code, class: Test::TradeCode do
    factory :source, :class => Test::Source do
      sequence(:code) { |n| (97 + n%26).chr }
      sequence(:name_en) { |n| "Source @{n}" }
    end

    factory :purpose, :class => Test::Purpose do
      sequence(:code) { |n| (97 + n%26).chr }
      sequence(:name_en) { |n| "Purpose @{n}" }
    end

    factory :term, :class => Test::Term do
      sequence(:code) { |n| [n, n+1, n+2].map{ |i|  (97 + i%26).chr }.join }
      sequence(:name_en) { |n| "Term @{n}" }
    end

    factory :unit, :class => Test::Unit do
      sequence(:code) { |n| [n, n+1, n+2].map{ |i|  (97 + i%26).chr }.join }
      sequence(:name_en) { |n| "Unit @{n}" }
    end
  end
end
