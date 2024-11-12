class Test::SpeciesListing < ApplicationRecord
  belongs_to :designation, class_name: 'Test::Designation'
end
