# TODO possibly use a view on top of taxon_concepts_mview
class TaxonConcept < ActiveRecord::Base
  self.table_name = :taxon_concepts_mview
  self.primary_key = :id

  def higher_taxa
    ['KINGDOM', 'PHYLUM', 'CLASS', 'ORDER', 'FAMILY'].map do |rank|
      [rank.downcase, send(:"#{rank.downcase}_name")]
    end.to_h
  end

  def synonyms
    # TODO
  end

end
