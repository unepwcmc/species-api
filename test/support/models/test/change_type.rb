class Test::ChangeType < ApplicationRecord
  belongs_to :designation, class_name: 'Test::Designation'
end
