# frozen_string_literal: true

module Pubid
  module Jis
    # Base class for supplement identifiers (Amendment, Explanation)
    # Supplements are modifications to base documents
    class SupplementIdentifier < SingleIdentifier
      attribute :base, Pubid::Jis::Identifier # Base document being supplemented
      attribute :number, :integer # Supplement number (optional for Explanation)

      # A supplement adds `base` and `number` to the attribute set, so it needs
      # its own key_value mapping. The nested base round-trips polymorphically
      # via its own _type.
      key_value do
        map "_type", to: :_type,
                     polymorphic_map: Pubid::Jis::Identifier::JIS_TYPE_MAP
        map "base", to: :base
        map "number", to: :number
        map "year", to: :year
        map "reaffirmed", to: :reaffirmed
        map "symbol", to: :symbol, render_empty: true
        # A supplement's code is always its base's code (see #code), so suppress
        # the inherited `code` mapping to avoid duplicating it in every row.
        map "code", with: { to: :skip_code_to, from: :skip_code_from }
      end

      # Inherit code from base document
      def code
        base&.code
      end

      # No-op custom (de)serializers that drop the redundant `code` key.
      def skip_code_to(_model, _parent); end

      def skip_code_from(_model, _value); end

      # Render as base + supplement notation
      def to_s(with_publisher: true)
        result = base.to_s(with_publisher: with_publisher)
        result += "/#{supplement_notation}"
        result += symbol_suffix
        result
      end

      # Override in subclasses
      def supplement_notation
        raise NotImplementedError, "Subclass must implement supplement_notation"
      end

      def ==(other)
        return false unless other.is_a?(SupplementIdentifier)
        return false unless other.class == self.class

        base == other.base &&
          number == other.number &&
          year == other.year
      end
    end
  end
end
