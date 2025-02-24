attributes :id, :full_name, :author_year, :rank, :name_status, :taxonomy, :updated_at, :active

extends 'api/v1/taxon_concepts/accepted_name', if: :is_accepted_name?
extends 'api/v1/taxon_concepts/accepted_name_associations', if: lambda { |tc| tc.is_accepted_name? && !@is_dump }
extends 'api/v1/taxon_concepts/synonym', if: :is_synonym?
extends 'api/v1/taxon_concepts/dumpable_associations', if: lambda { |tc| @is_dump }