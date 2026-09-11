# frozen_string_literal: true

module Pubid
  module Bsi
    module Identifiers
      # AdoptedEuropeanNorm wraps CEN identifiers
      # Example: "BS EN 10077-1:2006" where EN 10077-1:2006 is a CEN identifier object
      # Example: "BS EN ISO 8601:2019" where EN ISO 8601:2019 is a CEN AdoptedEuropeanNorm wrapping ISO
      class AdoptedEuropeanNorm < BritishStandard
        attribute :adopted, ::Pubid::Identifier, polymorphic: true # CEN object
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

        # Walk to the adopted document for the relaton-index key.
        #
        # The `#number` delegation below is not enough on its own: a
        # "DD ENV ISO 11079:1999" adopts a CenCenelec EuropeanPrestandard,
        # which is ITSELF a wrapper around the ISO standard, so the delegation
        # returned that wrapper's own (nil) number and the chain died one level
        # short. `#root` recurses, so it reaches the ISO standard however many
        # adoption layers sit in between.
        def root
          adopted ? adopted.root : self
        end

        # Delegate common methods to adopted identifier
        def number
          delegate_target&.number
        end

        def year
          delegate_target&.year if delegate_target&.methods&.include?(:year)
        end

        def date
          delegate_target&.date if delegate_target&.methods&.include?(:date)
        end

        def parts
          delegate_target&.parts if delegate_target&.methods&.include?(:parts)
        end

        def part
          delegate_target&.part if delegate_target&.methods&.include?(:part)
        end

        def subpart
          adopted&.subpart if adopted&.methods&.include?(:subpart)
        end

        private

        # The identifier that holds the number, part and date. For
        # "BS EN ISO 8848:2021" the adopted document is a CEN adoption of an
        # ISO standard, and the CEN adoption keeps no number of its own, so
        # read through it to the ISO standard. The CEN class used to do this
        # with delegating readers, which broke its serialization. `subpart`
        # keeps reading the CEN object, as it did before.
        def delegate_target
          target = adopted
          if target.is_a?(::Pubid::CenCenelec::Identifiers::AdoptedEuropeanNorm)
            target.adopted
          else
            target
          end
        end
      end
    end
  end
end
