require Rails.root + 'test/support/models/test/reference.rb'
require Rails.root + 'test/support/models/test/distribution.rb'

class Test::DistributionReference < ActiveRecord::Base
  belongs_to :reference, class_name: Test::Reference
  belongs_to :distribution, class_name: Test::Distribution
end
