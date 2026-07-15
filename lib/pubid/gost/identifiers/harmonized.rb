# frozen_string_literal: true

module Pubid
  module Gost
    module Identifiers
      # Harmonized standard. The GOST has been officially aligned with,
      # modified from, or adopted directly from one or more foreign
      # (typically ISO/IEC) standards. The parenthesized form is the
      # Russian/CIS garmonizatsiya convention.
      #
      # Examples:
      #   ГОСТ 25346-2013 (ISO 286-1:2010)
      #   ГОСТ 6032-2017 (ISO 3651-1:1998, ISO 3651-2:1998)
      #   ГОСТ 6996-66 (ИСО 4136-89, ИСО 5173-81, ИСО 5177-81)
      #
      # One GOST may harmonize with multiple foreign standards at once.
      # The slash form (IdenticalAdoption) is reserved for the strict IDT case.
      class Harmonized < Base
        attribute :base, ::Pubid::Gost::Identifier, polymorphic: true
        attribute :adopted_identifiers, ::Pubid::Identifier,
                  collection: true, polymorphic: true

        key_value do
          map "base",                to: :base
          map "adopted_identifiers", to: :adopted_identifiers
        end

        def self.type
          { key: :harmonized, title: "Harmonized Standard", short: nil }
        end

        def number; base&.number; end
        def year; base&.year; end
        def copublisher; base&.copublisher; end
        def subtype; base&.subtype; end
      end
    end
  end
end
