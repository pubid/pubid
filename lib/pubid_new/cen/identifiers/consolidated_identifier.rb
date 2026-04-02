# frozen_string_literal: true

require_relative "base"

module PubidNew
  module Cen
    module Identifiers
      # Consolidated Identifier - contains base document plus supplements
      # Example: "EN 196-3:2005+A1:2008" = [EN 196-3:2005, Amendment(base + params)]
      class ConsolidatedIdentifier < Base
        attribute :identifiers, Base, polymorphic: true, collection: true

        def to_s
          identifiers.map.with_index do |id, idx|
            if idx == 0
              # First identifier renders normally
              id.to_s
            elsif id.is_a?(Amendment)
              # Supplements render with "+" prefix (bundled/consolidated format)
              result = "+A#{id.amendment_number}"
              result += ":#{id.amendment_year}" if id.amendment_year
              result
            # Only render the amendment portion, not the full id.to_s
            elsif id.is_a?(Corrigendum)
              # Only render the corrigendum portion
              result = "+AC"
              result += id.corrigendum_number if id.corrigendum_number && !id.corrigendum_number.empty?
              if id.corrigendum_year
                result += ":#{id.corrigendum_year}"
                result += "-#{id.corrigendum_month}" if id.corrigendum_month && !id.corrigendum_month.empty?
              end
              result
            else
              # Other identifiers (should not happen in typical bundles) render with +
              "+#{id}"
            end
          end.compact.join
        end

        # Delegate to first identifier (base document)
        def publisher
          identifiers&.first&.publisher
        end

        def number
          identifiers&.first&.number
        end

        def year
          identifiers&.first&.year
        end

        def parts
          identifiers&.first&.parts
        end

        def type
          identifiers&.first&.type
        end
      end
    end
  end
end
