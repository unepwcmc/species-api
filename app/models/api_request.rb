# == Schema Information
#
# Table name: api_requests
#
#  id              :integer          not null, primary key
#  user_id         :integer
#  controller      :string(255)
#  action          :string(255)
#  format          :string(255)
#  params          :text
#  ip              :string(255)
#  response_status :integer
#  error_message   :text
#  created_at      :datetime
#  updated_at      :datetime
#

class ApiRequest < ApplicationRecord
  serialize :params, coder: JSON

  belongs_to :user, optional: true
end
