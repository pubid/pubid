# frozen_string_literal: true

module Pubid
  module Ieee
    module Identifiers
      # Adopted Standard Identifier
      # IEEE's adoption of another organization's standard
      # Example: "IEEE Standard No 18-1968 (ANSI C55.1-1968)"
      # This means IEEE adopted ANSI's standard C55.1-1968 as their Std No 18-1968
      class AdoptedStandard < Base
        # IEEE's identifier for this adopted standard
        attribute :ieee_identifier, Base, polymorphic: true

        # Original identifiers from ANSI/ISO/IEC/etc (array for multi-part adoptions)
        attribute :adopted_identifiers, Base, polymorphic: true,
                                              collection: true

        def to_s
          result = ieee_identifier.to_s
          if adopted_identifiers && !adopted_identifiers.empty?
            adopted_strs = adopted_identifiers.map(&:to_s)
            result += " (#{adopted_strs.join(' and ')})"
          end
          result
        end

        def publisher
          ieee_identifier&.publisher || "IEEE"
        end
      end
    end
  end
end
