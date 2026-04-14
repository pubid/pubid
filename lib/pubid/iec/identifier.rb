require_relative "../identifier"
# frozen_string_literal: true
require_relative "../components/typed_stage"

module Pubid
  module Iec
    class Identifier < ::Pubid::Identifier
      def self.parse(string)
        # Apply legacy update_codes normalization first, before any other preprocessing
        normalized = Core::UpdateCodes.apply(string, :iec)
        parsed = Pubid::Iec::Parser.new.parse(normalized)
        if parsed.nil? || parsed.empty?
          raise Pubid::Iec::Parser::ParseError,
                "Invalid identifier format"
        end

        Pubid::Iec::Builder.new(Pubid::Iec::Scheme).build(parsed)
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
