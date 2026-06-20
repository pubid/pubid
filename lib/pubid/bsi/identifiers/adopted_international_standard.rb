# frozen_string_literal: true

module Pubid
  module Bsi
    module Identifiers
      # AdoptedInternationalStandard wraps ISO/IEC identifiers directly
      # Example: "BS ISO 8601:2019" where ISO 8601:2019 is an ISO identifier object
      # Example: "BS IEC 62600:2020" where IEC 62600:2020 is an IEC identifier object
      class AdoptedInternationalStandard < BritishStandard
        attribute :adopted_identifier, ::Pubid::Identifier, polymorphic: true # ISO/IEC object
        attribute :edition, :string
        attribute :translation_lang, :string
        attribute :translation_upper, :string
        attribute :translation_suffix_type, :string # "version" or "Translation"
        attribute :reaffirmation_year, :string # For "(R2004)" notation
        attribute :expert_commentary, :boolean
        attribute :expert_commentary_topic, :string

        # Override self.type to return nil so this polymorphic wrapper is not
        # registered as a base type. Inherits `:bs` from BritishStandard which
        # would otherwise shadow it in Bsi.locate_type(:bs) auto-discovery.
        # AdoptedInternationalStandard is constructed explicitly by the builder,
        # not selected by type-code lookup.
        def self.type
          nil
        end

        def to_s
          render(format: :human)
        end

        # Delegate common methods to adopted identifier
        def number
          adopted_identifier&.number
        end

        def year
          adopted_identifier&.year if adopted_identifier&.methods&.include?(:year)
        end

        def date
          adopted_identifier&.date if adopted_identifier&.methods&.include?(:date)
        end

        def parts
          adopted_identifier&.parts if adopted_identifier&.methods&.include?(:parts)
        end

        def part
          adopted_identifier&.part if adopted_identifier&.methods&.include?(:part)
        end
      end
    end
  end
end
