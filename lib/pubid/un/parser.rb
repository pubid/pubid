# frozen_string_literal: true

require "parslet"

module Pubid
  module Un
    class Parser < Parslet::Parser
      rule(:slash) { str("/") }
      rule(:un_prefix) { (str("UN") >> str(" ")).maybe }
      rule(:token) { match("[A-Z0-9.]").repeat(1) }

      rule(:identifier) do
        un_prefix >>
          token.as(:token) >>
          (slash >> token.as(:token)).repeat(1)
      end

      rule(:root) { identifier }

      def self.parse(input)
        new.parse(input)
      end
    end
  end
end
