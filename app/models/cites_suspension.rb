class CitesSuspension < ActiveRecord::Base
  after_initialize :readonly!
  self.table_name = :api_cites_suspensions_view
  self.primary_key = :id

  translates :geo_entity

  belongs_to :taxon_concept
  scope :in_scope, ->(scope) {
    if scope == :current
      where(is_current: true)
    elsif scope == :historic
      where(is_current: false)
    else
      where(nil)
    end
  }

end
