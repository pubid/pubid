# frozen_string_literal: true

module Pubid
  # Identifier that
  module Iso
    class Identifier < ::Pubid::Identifier
      def self.parse(string)
        parsed = Pubid::Iso::Parser.new.parse(string)
        if parsed.nil? || parsed.empty?
          raise Pubid::Iso::Parser::ParseError,
                "Invalid identifier format"
        end

        Pubid::Iso::Builder.new(Pubid::Iso::Scheme).build(parsed)
      end
    end
  end
end
