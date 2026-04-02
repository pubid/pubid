# frozen_string_literal: true

module Pubid
  module Etsi
    module Identifiers
      # Base class for ETSI supplements (Amendment, Corrigendum)
      class SupplementIdentifier < Base
        attribute :base, Pubid::Etsi::Identifiers::Base
        attribute :number, :integer

        # Inherit attributes from base
        def type
          base.type
        end

        def code
          base.code
        end

        def version
          base.version
        end

        def date
          base.date
        end

        # Render as: ETSI TYPE CODE/SUPPLEMENTS VERSION (DATE)
        # When multiple supplements are present, they appear in order: /A1/C1
        def to_s
          supplement_notations = collect_supplement_notations(self, [])
          # Get the actual base ETSI standard (not supplements)
          actual_base = find_actual_base(base)
          code_with_supplements = "#{actual_base.code}#{supplement_notations.join}"
          "#{actual_base.publisher} #{actual_base.type} #{code_with_supplements} #{actual_base.version} (#{actual_base.date.year}-#{actual_base.date.month.to_s.rjust(
            2, '0'
          )})"
        end

        # Recursively collect supplement notations from the supplement chain
        def collect_supplement_notations(current_supplement, notations)
          if current_supplement.is_a?(SupplementIdentifier)
            # Add this supplement's notation at the beginning (because supplements wrap from outside in)
            notations.unshift("/#{current_supplement.supplement_notation}")
            # Continue collecting from the base if it's also a supplement
            if current_supplement.base.is_a?(SupplementIdentifier)
              collect_supplement_notations(current_supplement.base, notations)
            else
              notations
            end
          else
            notations
          end
        end

        # Find the actual base ETSI standard (not supplements)
        def find_actual_base(current_base)
          if current_base.is_a?(SupplementIdentifier)
            find_actual_base(current_base.base)
          else
            current_base
          end
        end

        def supplement_notation
          raise NotImplementedError
        end

        def ==(other)
          return false unless other.is_a?(SupplementIdentifier)
          return false unless other.class == self.class

          base == other.base && number == other.number
        end

        # Include supplement notation in serialization
        def base_hash
          hash = super
          # ETSI supplements need the type (e.g., "ETS", "TR") from the base document
          hash[:type] = base.type if base.respond_to?(:type) && base.type
          hash[:supplement_notation] = supplement_notation
          hash[:supplement_type] = self.class.name.split("::").last.downcase
          hash
        end
      end
    end
  end
end
