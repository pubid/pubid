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
            else
              # Supplements render with appropriate prefix
              if id.is_a?(Amendment)
                # Use separator from Amendment object
                "#{id.separator}A#{id.amendment_number}:#{id.amendment_year}"
              elsif id.is_a?(Corrigendum)
                result = "+AC"
                result += id.corrigendum_number if id.corrigendum_number && !id.corrigendum_number.empty?
                result += ":#{id.corrigendum_year}" if id.corrigendum_year
                result
              else
                id.to_s
              end
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