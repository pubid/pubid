# frozen_string_literal: true

module Pubid
  module Ieee
    module Identifiers
      # Adopted Standard Identifier
      # IEEE's adoption of another organization's standard
      # Example: "IEEE Standard No 18-1968 (ANSI C55.1-1968)"
      # This means IEEE adopted ANSI's standard C55.1-1968 as their Std No 18-1968
      class AdoptedStandard < Identifier
        # IEEE's identifier for this adopted standard
        attribute :ieee_identifier, Identifier, polymorphic: true

        # Original identifiers from ANSI/ISO/IEC/etc (array for multi-part adoptions)
        attribute :adopted_identifiers, Identifier, polymorphic: true,
                                              collection: true

        def publisher
          ieee_identifier&.publisher || "IEEE"
        end
      end
    end
  end
end
