# frozen_string_literal: true

module Pubid
  module Jis
    # Base class for supplement identifiers (Amendment, Explanation)
    # Supplements are modifications to base documents
    class SupplementIdentifier < Identifiers::Base
      attribute :base, Pubid::Jis::Identifiers::Base # Base document being supplemented
      attribute :number, :integer # Supplement number (optional for Explanation)

      def initialize(base:, number: nil, year: nil, **args)
        @base = base
        @number = number
        # Year comes from parameter or base document
        supplement_year = year || base&.year
        # Call super with year to set it in Base
        super(year: supplement_year, **args)
      end

      # Inherit code from base document
      def code
        base&.code
      end

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
