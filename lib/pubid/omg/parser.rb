# frozen_string_literal: true

require "parslet"

module Pubid
  module Omg
    # Parslet grammar for OMG specification identifiers.
    #
    # Accepts:
    #   OMG {ACRONYM}[ {VERSION}]
    #
    # ACRONYM is uppercase letters/digits, at least 1 char.
    # VERSION is digits/dots/spaces/beta+space+digit, e.g. "1.0", "2.5.1",
    # "5 beta 3".
    class Parser < Parslet::Parser
      rule(:space) { str(" ") }

      # Acronym: starts with uppercase, may contain uppercase + lowercase +
      # digits (covers "SysML", "AMI4CCM", "UML", "CORBA", "BMM", ...).
      rule(:acronym) { (match("[A-Z]") >> match("[A-Za-z0-9]").repeat).as(:acronym) }

      # Version: digits with optional dots, optionally followed by " beta N".
      rule(:version) do
        (match("[0-9]").repeat(1) >>
          (str(".") >> match("[0-9]").repeat(1)).repeat >>
          (str(" beta ") >> match("[0-9]").repeat(1)).maybe).as(:version)
      end

      rule(:identifier) do
        str("OMG") >> space >> acronym >> (space >> version).maybe
      end

      rule(:root) { identifier }

      def self.parse(input)
        new.parse(input)
      end
    end
  end
end
