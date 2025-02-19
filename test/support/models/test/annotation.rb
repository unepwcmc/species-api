class Test::Annotation < ApplicationRecord
  belongs_to :event, class_name: 'Test::Event', optional: true
  belongs_to :original_annotation, foreign_key: :original_id, class_name: 'Test::Annotation', optional: true
  belongs_to :created_by, foreign_key: :created_by_id, class_name: 'User', optional: true
  belongs_to :updated_by, foreign_key: :updated_by, class_name: 'User', optional: true

  has_many :listing_changes,
    class_name: 'Test::ListingChange',
    dependent: :nullify

  has_many :hashed_listing_changes,
    class_name: 'Test::ListingChange',
    dependent: :nullify,
    foreign_key: :hash_annotation_id,
    inverse_of: :hash_annotation
end
