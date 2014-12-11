FactoryGirl.define do
  factory :user do
    name "John"
    sequence(:email) { |n| "user#{n}@example.com" }
    password "test1234"
    role 'api'
  end
end