require_relative "../identifier"

module PubidNew
  module Ansi
    # Base ANSI identifier class
    class Identifier < ::PubidNew::Identifier
      def self.parse(string)
        parsed = PubidNew::Ansi::Parser.new.parse(string)
        PubidNew::Ansi::Builder.new(PubidNew::Ansi::Scheme).build(parsed)
      end
    end
  end
end