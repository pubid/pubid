# frozen_string_literal: true

require "parslet"

module Pubid
  module Gb
    # Parslet grammar for Chinese Standard identifiers.
    #
    # Accepts the canonical printed form
    #
    #   {PUBLISHER}[/{TYPE}] {NUMBER}[.{PART}][-|—{YEAR}] [(all parts)]
    #
    # PUBLISHER is one of the leading tokens from PREFIXES (GB, GB/T, JB,
    # T/GZAEPI, ...). TYPE is T (recommended), Z (guideline), or omitted.
    # YEAR is 4 digits, separated by either ASCII dash or em-dash (Chinese
    # typography uses the em-dash form).
    class Parser < Parslet::Parser
      rule(:space)  { str(" ") }
      rule(:dot)    { str(".") }
      rule(:dash)   { str("-") | str("—") }
      rule(:digits) { match("[0-9]").repeat(1) }

      # Publisher token: national/industry codes (1-3 letters, optionally
      # followed by /T or /Z) OR social-group form "T/{ACRONYM}".
      rule(:publisher_code) do
        # Social-group form: "T/" then 2+ uppercase letters/digits.
        (str("T/") >> match("[A-Z0-9]").repeat(1)).as(:publisher_code) |
          # Standard form: 1-3 letters, optional slash-T-or-Z.
          (match("[A-Z]").repeat(1, 3) >>
            (str("/T") | str("/Z")).maybe).as(:publisher_code)
      end

      # Mandate category captured separately when the publisher token didn't
      # already include it. Allows "GB/T" (inline) and "GB" + " T" (separate)
      # to both parse.
      rule(:mandate_suffix) do
        (str("/") >> (str("T") | str("Z")).as(:mandate)).maybe
      end

      rule(:number) { digits.as(:number) }
      rule(:part)   { dot >> digits.as(:part) }
      rule(:year)   { (dash >> match("[0-9]").repeat(4, 4).as(:year)).maybe }
      rule(:all_parts_flag) do
        (space >> str("(") >> str("all parts") >> str(")")).as(:all_parts)
      end

      rule(:identifier) do
        publisher_code >>
          space >>
          number >>
          part.maybe >>
          year >>
          all_parts_flag.maybe
      end

      rule(:root) { identifier }

      def self.parse(input)
        new.parse(input)
      end
    end
  end
end
