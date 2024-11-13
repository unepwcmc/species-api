class Test::Event < ApplicationRecord
  belongs_to :designation, class_name: 'Test::Designation', optional: true
  belongs_to :created_by, foreign_key: :created_by_id, class_name: 'User', optional: true
  belongs_to :updated_by, foreign_key: :updated_by, class_name: 'User', optional: true
end
