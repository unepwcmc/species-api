# Most relevant relationships belong to accepted names, so this file focuses
# just on the attributes relating to accepted names.

node(:higher_taxa) { |tc| tc.higher_taxa }
node(:synonyms) { |tc| tc.synonyms }

node(:common_names) do |tc|
  (tc.common_names_list || tc.common_names).map do |cn|
    # Can't use partial+attributes because these might just be hashes
    {
      name: cn['name'],
      language: cn['iso_code1']
    }
  end
end

# These are not the listing records, just the code, e.g I/II, A, B, etc.
attribute :cites_listing
attribute :eu_listing
