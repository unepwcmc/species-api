require Rails.root + 'test/support/models/test/language.rb'
class Test::TaxonCommon < ActiveRecord::Base
  belongs_to :language, class_name: Test::Language
end
