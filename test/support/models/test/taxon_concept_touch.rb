class Test::TaxonConceptTouch

  def after_save(record)
    record.taxon_concept && record.taxon_concept.update_attribute(:dependents_updated_at, Time.now)
  end

end
