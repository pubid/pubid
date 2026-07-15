# frozen_string_literal: true

require "parslet"

module Pubid
  module Iana
    # Parslet grammar for IANA registry identifiers.
    #
    # Accepts the authoritative printed form "IANA <slug>[/<sub-slug>]" as well
    # as a bare index-key slug (no "IANA " prefix). The optional prefix is
    # consumed and discarded — the renderer always re-emits it.
    #
    # Slugs use only [a-zA-Z0-9._-] and contain at most one "/", so a plain
    # character-class repeat parses them; there is no ReDoS surface.
    class Parser < Parslet::Parser
      # A single registry slug: letters, digits, dot, underscore, hyphen.
      rule(:slug) { match['a-zA-Z0-9._\-'].repeat(1) }

      # Optional publisher prefix. The trailing space is required, so a
      # space-free slug never triggers it; PEG `.maybe` backtracks the whole
      # sequence if the space is absent (e.g. a slug that happens to start
      # "IANA...").
      rule(:iana_prefix) { (str("IANA") >> str(" ")).maybe }

      rule(:identifier) do
        iana_prefix >>
          slug.as(:registry) >>
          (str("/") >> slug.as(:sub_registry)).maybe
      end

      rule(:root) { identifier }

      def self.parse(input)
        new.parse(input)
      end
    end
  end
end
