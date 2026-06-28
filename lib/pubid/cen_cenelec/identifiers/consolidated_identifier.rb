# frozen_string_literal: true

module Pubid
  module CenCenelec
    module Identifiers
      # Consolidated Identifier - contains base document plus supplements
      # Example: "EN 196-3:2005+A1:2008" = [EN 196-3:2005, Amendment(base + params)]
      class ConsolidatedIdentifier < Base
        attribute :identifiers, Base, polymorphic: true, collection: true

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
