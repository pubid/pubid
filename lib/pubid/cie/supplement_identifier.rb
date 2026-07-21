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
