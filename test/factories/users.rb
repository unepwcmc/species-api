# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  name                   :string(255)      not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  role                   :string(255)      default("default")
#  authentication_token   :string(255)
#

FactoryBot.define do
  factory :user do
    name { 'John' }
    sequence(:email) { |n| "user#{n}@example.com" }
    password { 'test1234' }
    role { 'api' }
    is_cites_authority { true }
    organisation { 'Ministry of Environment' }
  end
end
