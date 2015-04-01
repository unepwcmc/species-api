require Rails.root + 'test/support/models/test/rank.rb'
require Rails.root + 'test/support/models/test/taxon_name.rb'
require Rails.root + 'test/support/models/test/taxonomy.rb'

class Test::TaxonConcept < ActiveRecord::Base
  belongs_to :rank, class_name: Test::Rank
  belongs_to :taxon_name, class_name: Test::TaxonName
  belongs_to :taxonomy, class_name: Test::Taxonomy
  belongs_to :parent, foreign_key: :parent_id, class_name: Test::TaxonConcept

  #initializes data and full name with values from parent
  before_validation do |taxon_concept|
    data = taxon_concept.data || {}
    data['rank_name'] = taxon_concept.rank && taxon_concept.rank.name
    if taxon_concept.parent
      data = data.merge taxon_concept.parent.data.slice(
        'kingdom_id', 'kingdom_name', 'phylum_id', 'phylum_name', 'class_id',
        'class_name', 'order_id', 'order_name', 'family_id', 'family_name',
        'subfamily_id', 'subfamily_name', 'genus_id', 'genus_name', 'species_id',
        'species_name'
      )
    end
    taxon_concept.data = data
    taxon_concept.full_name = if taxon_concept.rank && taxon_concept.parent &&
      taxon_concept.name_status == 'A'
      rank_name = taxon_concept.rank.name
      parent_full_name = taxon_concept.parent.full_name
      name = taxon_concept.taxon_name && taxon_concept.taxon_name.scientific_name
      if [Test::Rank::SPECIES, Test::Rank::SUBSPECIES].include? rank_name
        "#{parent_full_name} #{name.downcase}"
      elsif rank_name == Test::Rank::VARIETY
        "#{parent_full_name} var. #{name.downcase}"
      else
        name
      end
    else
      taxon_concept.taxon_name && taxon_concept.taxon_name.scientific_name
    end
  end

  after_destroy do |taxon_concept|
    tcv = Test::TaxonConceptVersion.new(
      event: 'destroy',
      item_id: taxon_concept.id,
      item_type: 'TaxonConcept',
      taxon_concept_id: taxon_concept.id,
      taxonomy_name: taxon_concept.taxonomy.name,
      rank_name: taxon_concept.rank.name,
      full_name: taxon_concept.full_name,
      author_year: taxon_concept.author_year,
      name_status: taxon_concept.name_status
    )
    tcv.save
    puts tcv.errors.inspect
  end

end
