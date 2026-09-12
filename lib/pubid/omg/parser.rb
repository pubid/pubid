# frozen_string_literal: true

require "parslet"

module Pubid
  module Omg
    # Parslet grammar for OMG specification identifiers.
    #
    # Accepts:
    #   OMG {ACRONYM}[ {VERSION}][ {PART}]
    #
    # ACRONYM is uppercase letters/digits, at least 1 char.
    # VERSION is digits/dots, optionally followed by a beta label, e.g. "1.0",
    # "2.5.1", "5 beta 3", "2.5 beta".
    # PART is the volume or format segment, e.g. "Superstructure", "PDF". A
    # space or a slash separates it.
    class Parser < ::Pubid::Parser::Grammar
      rule(:space) { str(" ") }

      # Acronym: starts with uppercase, may contain uppercase + lowercase +
      # digits (covers "SysML", "AMI4CCM", "UML", "CORBA", "BMM", ...).
      rule(:acronym) { (match("[A-Z]") >> match("[A-Za-z0-9]").repeat).as(:acronym) }

      # Version: digits with optional dots, optionally followed by " beta" and
      # an optional beta number. OMG writes the label both ways: the document
      # at /spec/UML/2.5/Beta1 gives its own version as "2.5 beta", and DDS 1.4
      # supersedes /spec/DDS/1.4/Beta2.
      #
      # The beta number must stay optional here. The document part below would
      # otherwise swallow a bare "beta" and report the version as "2.5" — a
      # silent wrong answer, not a parse failure.
      #
      # Both halves of the beta label end at a word boundary. Parslet never
      # backtracks into a `.maybe` that already succeeded, so an unanchored
      # literal makes the version eat the front of a document part and then
      # reject the whole identifier: "OMG DDS 1.4 beta2" and
      # "OMG DDS 1.4 betawave" would raise instead of reading the part.
      rule(:word_boundary) { match("[A-Za-z0-9]").absent? }

      rule(:beta) do
        str(" beta") >> word_boundary >>
          (space >> match("[0-9]").repeat(1) >> word_boundary).maybe
      end

      rule(:version) do
        (match("[0-9]").repeat(1) >>
          (str(".") >> match("[0-9]").repeat(1)).repeat >>
          beta.maybe).as(:version)
      end

      # OMG separates the document part with either a space or a slash. The
      # renderer prints a space, so the two spellings of one document stay
      # equal.
      rule(:part_separator) { space | str("/") }

      # Document part: the volume or format segment OMG puts after the
      # version. UML 2.1.1 is two documents, Superstructure and
      # Infrastructure, and the URL carries the same segment
      # (/spec/UML/2.1.1/Superstructure). A format name (/spec/DDS/1.4/PDF)
      # occupies the same position.
      rule(:part) { match("[A-Za-z0-9]").repeat(1).as(:part) }

      rule(:identifier) do
        str("OMG") >> space >> acronym >>
          (space >> version).maybe >>
          (part_separator >> part).maybe
      end

      rule(:root) { identifier }

      def self.parse(input)
        new.parse(input)
      end
    end
  end
end
