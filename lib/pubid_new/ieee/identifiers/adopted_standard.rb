# frozen_string_literal: true

require_relative "base"

module PubidNew
  module Ieee
    module Identifiers
      # Adopted Standard Identifier
      # IEEE's adoption of another organization's standard
      # Example: "IEEE Standard No 18-1968 (ANSI C55.1-1968)"
      # This means IEEE adopted ANSI's standard C55.1-1968 as their Std No 18-1968
      class AdoptedStandard < Base
        # IEEE's identifier for this adopted standard
        attribute :ieee_identifier, Base, polymorphic: true

        # Original identifier from ANSI/ISO/IEC/etc
        attribute :adopted_identifier, Base, polymorphic: true

        def to_s
          result = ieee_identifier.to_s
          result += " (#{adopted_identifier})" if adopted_identifier
          result
        end

        def publisher
          ieee_identifier&.publisher || "IEEE"
        end
      end
    end
  end
end