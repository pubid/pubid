# frozen_string_literal: true

require "lutaml/model"

module Pubid
  module Cie
    module Identifiers
      # Supplement identifier for CIE (-SPN / -SPN.P notation).
      # Wraps a nested base (the base Standard); the "-SPN" is
      # inserted after the base number, so to_s renders from the base's parts.
      # Examples: CIE 121-SP1:2009, CIE 198-SP1.4:2011, CIE DIS 025-SP1/E:2019
      class Supplement < SupplementIdentifier
        # +number+ (the "-SPN" ordinal) is inherited from SupplementIdentifier.
        attribute :part, :string # "1" in "SP1.1", "4" in "SP1.4"

        # Uniform supplement interface (shared with Corrigendum).
        def supplement_type
          :supplement
        end

        def supplement_year
          base&.year
        end

        def to_s
          b = base
          parts = ["CIE"]
          parts << b.stage if b.respond_to?(:stage) && b.stage

          core = "#{b.number}-SP#{number}"
          core += ".#{part}" if part
          parts << core
          result = parts.join(" ")

          # Language with slash (before year), e.g. "/E"
          if b.language && b.language.format == "slash_colon"
            result += "/#{b.language.code}"
          end

          # Supplements always use the current (colon) style.
          result += ":#{b.year}" if b.year
          result
        end
      end
    end
  end
end
