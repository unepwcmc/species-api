collection @distributions
attributes :iso_code2, :tags
attributes :geo_entity_type => :type, :citations => :references

language =  case @language
            when 'es'
              'name_es'
            when 'fr'
              'name_fr'
            else
              'name_en'
            end

node(:name) { |distribution| distribution.read_attribute(language) }


