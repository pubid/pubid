# frozen_string_literal: true

require "parslet"

module Pubid
  module Adobe
    # Parslet grammar for Adobe identifiers.
    #
    # Canonical citation forms (what the renderer produces):
    #
    #   Adobe TN 5014                  (tech note; replaces the older
    #                                    "Adobe Technical Note #5014")
    #   Adobe Publication adobe-glyph-list
    #   Adobe Publication adobe-japan1-7
    #
    # The parser also accepts these legacy forms for back-compat:
    #
    #   Adobe Technical Note #5014
    #   Adobe Technical Note 5014
    #   Adobe TN5014                   (no space)
    #   ATN5014                        (short alias)
    #   5014                           (bare number; data-repo context)
    #   adobe-glyph-list               (bare slug)
    class Parser < Parslet::Parser
      include ::Pubid::Parser::CommonParseRules

      root :identifier

      rule(:space)  { str(" ") }
      rule(:space?) { space.maybe }
      rule(:hash)   { str("#") }
      rule(:dot)    { str(".") }
      rule(:dash)   { str("-") }

      # Canonical short prefix: "Adobe TN" with optional trailing space.
      # Matches both "Adobe TN 5014" and "Adobe TN5014".
      rule(:tech_note_tn_prefix) do
        str("Adobe") >> space >> str("TN") >> space?.maybe
      end

      # Legacy long prefix: "Adobe Technical Note" with optional "#".
      rule(:tech_note_long_prefix) do
        str("Adobe") >> space >> str("Technical") >> space >> str("Note") >>
          (space? >> hash.maybe >> space?).maybe
      end

      # Legacy short alias: "ATN" with optional trailing space.
      rule(:tech_note_atn_prefix) do
        str("ATN") >> space?.maybe
      end

      rule(:tech_note_prefix) do
        tech_note_tn_prefix | tech_note_long_prefix | tech_note_atn_prefix
      end

      rule(:digits) do
        match("[0-9]").repeat(1)
      end

      # 4-digit tech note number, optionally followed by ".<Slug>" from
      # the filename form. The slug is captured but not required.
      rule(:slug_chars) do
        match("[A-Za-z0-9_]").repeat(1)
      end

      rule(:tech_note) do
        (tech_note_prefix >>
          digits.as(:number) >>
          (dot >> slug_chars.as(:slug)).maybe).as(:tech_note)
      end

      # Bare number form (e.g. when the data repo passes just "5014"
      # extracted from a filename). Not advertised in user docs; used
      # internally by AdobeFetcher::Docid.
      rule(:bare_number) do
        digits.as(:number).as(:tech_note_bare)
      end

      # "Adobe Publication " prefix. Matched literally then discarded —
      # the publication slug/version is parsed by the inner rule.
      rule(:publication_prefix) do
        str("Adobe") >> space >> str("Publication") >> space
      end

      # Publication slug. Lowercase ASCII letters and digits joined by `-`.
      # Each segment starts with a letter (so a trailing `-<digits>` is
      # unambiguously a version suffix, not part of the slug).
      rule(:slug_segment) do
        match("[a-z]") >> match("[a-z0-9]").repeat
      end

      rule(:slug_inner) do
        slug_segment >> (dash >> slug_segment).repeat
      end

      rule(:publication_with_version) do
        (slug_inner.as(:slug) >> dash >> digits.as(:version)).as(:publication_version)
      end

      rule(:publication_slug_or_version) do
        # Try with-version first so `adobe-japan1-7` doesn't get captured
        # as slug `adobe-japan1-7` with no version. The flat `:slug` form
        # is the fallback for unversioned slugs.
        publication_with_version | slug_inner.as(:slug)
      end

      rule(:publication) do
        # Optional "Adobe Publication " prefix. The prefix is consumed
        # but not captured — the inner rule produces :slug or
        # :publication_version as before.
        publication_prefix.maybe >> publication_slug_or_version
      end

      rule(:identifier) do
        tech_note | bare_number | publication
      end

      # Parse a string and return the raw parslet tree.
      # @param string [String]
      # @return [Hash]
      def self.parse(string)
        raise ArgumentError, ::Pubid::INPUT_TOO_LONG_MESSAGE if string.length > ::Pubid::MAX_INPUT_LENGTH

        new.parse(string.strip)
      end
    end
  end
end
