require_relative "../identifier"
# frozen_string_literal: true
require_relative "../components/typed_stage"

module Pubid
  module Iec
    class Identifier < ::Pubid::Identifier
      def self.parse(string)
        # Delegate to Pubid::Iec.parse which applies UpdateCodes normalization
        Pubid::Iec.parse(string)
      end

      # Generate URN. Lives on the base IEC Identifier (rather than only on
      # SingleIdentifier) so wrapper classes — VapIdentifier, FragmentIdentifier,
      # SheetIdentifier, ConsolidatedIdentifier — also inherit it. The
      # dispatch in UrnGenerator#generate routes to the right
      # `generate_<wrapper>_urn` per identifier class.
      def to_urn
        require_relative "urn_generator"
        UrnGenerator.new(self).generate
      end
    end
  end
end
