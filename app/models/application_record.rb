class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  # This is probably a terrible idea - rehydrate models from json structures
  # so that we can cache the structures, since we cannot cache the models in
  # recent Rails versions.
  def self.hydrate(hydratable)
    model_class = self

    if hydratable.nil?
      return hydratable
    elsif hydratable.is_a? ActiveRecord::Base
      hydratable
    elsif hydratable.is_a? Array
      hydratable.map do |item|
        model_class.hydrate(item)
      end
    elsif hydratable.is_a? Hash
      column_names = model_class.column_names

      association_names =
        model_class.reflect_on_all_associations.map(&:name).map(&:to_s)

      remaining_attrs = hydratable.except *column_names, *association_names

      instance = model_class.new(
        **(hydratable.except(*association_names).slice(*column_names))
      )

      if model_class.primary_key && instance.send(
        model_class.primary_key.to_sym
      )
        instance.instance_variable_set(:@new_record, false)
      end

      remaining_attrs.each do |attr_name, attr_val|
        setter_name = "#{attr_name}=".to_sym

        if instance.methods.include? setter_name
          instance.send(setter_name, attr_val)
        else
          raise ArgumentError, "Unknown association or attribute #{
            model_class
          }.#{
            attr_name
          } in hydrate"
        end
      end

      if model_class.primary_key && instance.send(
        model_class.primary_key.to_sym
      )
        instance.instance_variable_set(:@new_record, false)
      end

      # hydrate associations
      model_class.reflect_on_all_associations.each do |reflection|
        if hydratable.has_key? reflection.name
          association = instance.association(reflection.name)

          associated_class = association.klass
          associated_records = associated_class.hydrate(
            hydratable[reflection.name]
          )

          if associated_records
            if reflection.collection?
              raise ArgumentError, (
                "Expected array of #{
                  association_class
                } for #{
                  model_class.name
                }.#{
                  reflection.name
                } in hydrate, got #{
                  hydratable.class.name
                }"
              ) unless associated_records.is_a? Array

              association.target.concat(associated_records)
            else
              association.target = associated_records
            end
          end

          association.loaded!
        end
      end

      instance
    else
      raise ArgumentError, (
        "Expected array, hash or ActiveRecord::Base in #{
          model_class.name
        }.hydrate, got #{
          hydratable.class.name
        }"
      )
    end
  end
end