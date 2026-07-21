# frozen_string_literal: true

module Pubid
  module Cie
    # Base class for CIE supplement identifiers (Supplement, Corrigendum).
    #
    # Like ISO/IEC/BSI/JCGM, a CIE supplement wraps its base document as a
    # nested full identifier (+base+, a Pubid::Cie::Identifier),
    # rather than flat base_number/base_year strings. This lets CIE supplements
    # participate in the shared base_document / drop_supplements / matches?
    # vocabulary relaton uses to match a citation to its base standard.
    #
    # Concrete subtypes: Supplement (-SPN), Corrigendum (/CorN).
    class SupplementIdentifier < Identifier
      attribute :base, Identifier, polymorphic: true
      # The supplement's/corrigendum's own ordinal ("1" in -SP1 / Cor1).
      # :string overrides the base ::Pubid::Identifier Components::Code type.
      # (Not the index key — relaton keys on #root.number, the base standard's.)
      attribute :number, :string

      # Uniform, class-agnostic supplement interface (shared by Supplement and
      # Corrigendum) so callers never special-case corrigenda. +supplement_type+
      # and +supplement_year+ are defined per subclass.
      def supplement_number
        number
      end

      # The underlying standard, with supplement layer(s) peeled recursively.
      def base_document
        base&.base_document || self
      end

      # Dropping one supplement layer yields the wrapped base identifier.
      def drop_supplements
        base || self
      end
    end
  end
end
