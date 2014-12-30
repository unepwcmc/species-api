class Test::SpeciesListing < ActiveRecord::Base
  belongs_to :designation, class_name: Test::Designation
end
