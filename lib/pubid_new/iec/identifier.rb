require_relative "../identifier"
require_relative "../components/typed_stage"

module PubidNew
  module Iec
    class Identifier < ::PubidNew::Identifier
      def self.parse(string)
        parsed = PubidNew::Iec::Parser.new.parse(string)
        if parsed.nil? || parsed.empty?
          raise PubidNew::Iec::Parser::ParseError,
                "Invalid identifier format"
        end

        PubidNew::Iec::Builder.new(PubidNew::Iec::Scheme).build(parsed)
      end
    end
  end
end
