require_relative "../identifier"
# frozen_string_literal: true
require_relative "../components/typed_stage"

module Pubid
  module Iec
    class Identifier < ::Pubid::Identifier
      def self.parse(string)
        # Route URN strings to the URN parser (mirrors Iso::Identifier.parse)
        if Pubid::FormatDetector.detect(string) == :urn
          return Pubid::Iec::UrnParser.parse(string)
        end

        # Apply legacy update_codes normalization first, before any other preprocessing
        normalized = Core::UpdateCodes.apply(string, :iec)
        parsed = Pubid::Iec::Parser.new.parse(normalized)
        if parsed.nil? || parsed.empty?
          raise Pubid::Iec::Parser::ParseError,
                "Invalid identifier format"
        end

        Pubid::Iec::Builder.new(Pubid::Iec::Scheme).build(parsed)
      end
    end
  end
end
