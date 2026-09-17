# frozen_string_literal: true

module Pubid
  module Bsi
    module Identifiers
      # AdoptedEuropeanNorm wraps CEN identifiers
      # Example: "BS EN 10077-1:2006" where EN 10077-1:2006 is a CEN identifier object
      # Example: "BS EN ISO 8601:2019" where EN ISO 8601:2019 is a CEN AdoptedEuropeanNorm wrapping ISO
      class AdoptedEuropeanNorm < BritishStandard
        include RootIdentity

        # The adopted CEN document, under the uniform parent accessor. `#root`
        # and `#base_document` are inherited and walk it, so this class needs
        # neither an override nor the delegating readers it used to carry.
        attribute :base, ::Pubid::Identifier, polymorphic: true
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
        # AdoptedEuropeanNorm is constructed explicitly by the builder, not
        # selected by type-code lookup.
        def self.type
          nil
        end

      end
    end
  end
end
