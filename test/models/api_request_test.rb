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

require 'test_helper'

class ApiRequestTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
