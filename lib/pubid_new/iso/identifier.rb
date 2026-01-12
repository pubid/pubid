require_relative "../identifier"
require_relative "../components/typed_stage"

module PubidNew
  # Identifier that
  module Iso
    class Identifier < ::PubidNew::Identifier
      def self.parse(string)
        parsed = PubidNew::Iso::Parser.new.parse(string)
        if parsed.nil? || parsed.empty?
          raise PubidNew::Iso::Parser::ParseError,
                "Invalid identifier format"
        end

        PubidNew::Iso::Builder.new(PubidNew::Iso::Scheme).build(parsed)
      end
    end
  end
end
