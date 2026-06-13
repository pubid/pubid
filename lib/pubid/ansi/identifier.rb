# frozen_string_literal: true

module Pubid
  module Ansi
    # Base ANSI identifier class
    class Identifier < ::Pubid::Identifier
      def self.parse(string)
        parsed = Pubid::Ansi::Parser.new.parse(string)
        Pubid::Ansi::Builder.new.build(parsed)
      end
    end
  end
end
