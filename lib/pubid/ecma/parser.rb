# frozen_string_literal: true

module Pubid
  module Ecma
    # Grammar for ECMA identifiers.
    #
    # Four printed forms:
    #   ECMA-411          standard
    #   ECMA-418-1        standard with part
    #   ECMA TR/101       technical report
    #   ECMA MEM/1970     memento
    #
    # Any of them may carry an edition and a volume, in that order:
    #   ECMA-269 ed3      third edition
    #   ECMA-402 ed5.1    decimal edition (real: ECMA-402)
    #   ECMA-269 ed3 vol2 second volume of the third edition
    #
    # Each branch captures its number under a distinct key so the builder can
    # pick the identifier class without a separate type token. Numbers are kept
    # as strings to preserve any leading zeros.
    #
    # The grammar reads exactly one edition spelling — the glued " ed<N>" —
    # while the SDO's own cover and the natural human spellings differ, so
    # {Parser.normalize_input} rewrites those faces onto the glued token
    # before the artifact sees them (pre-parse alias; the baked grammar is
    # untouched). A canonical face passes through byte-identically.
    class Parser
      # The human edition spellings that alias the glued " ed<N>" token
      # (pubid#698), in rewrite order. Each rule rewrites into the exact
      # canonical face, so the parse (and therefore the render, the URN and
      # the index key) is the one " ed<N>" already produces.
      #
      #   ECMA-262 Edition 5.1   the document cover's own form
      #   ECMA-262 ed. 5.1       dotted, spaced
      #   ECMA-262 ed 5.1        spaced, undotted
      #   ECMA-262 ed.5.1        dotted, unspaced
      #   ECMA 262 5.1           bare trailing edition
      #
      # " ed5.1" (no separator) is the grammar's own face and is left alone;
      # a " vol<N>" number is never rewritten — the bare-trailing rule fires
      # only behind a document number's own digit, so "ECMA-269 ed3 vol2"
      # and even the spaced "… vol 2" keep their volume.
      EDITION_ALIASES = [
        # "Edition <N>" starts mid-word, so the replacement carries no space
        # of its own — the space before it is kept as-is.
        [/\bedition[.\s]*(\d+(?:\.\d+)?)\b/i, 'ed\1'],
        # "ed. <N>" / "ed <N>" / "ed.<N>": same mid-word shape. The glued
        # "ed5.1" has no separator after "ed" and cannot match [.\s]+, so a
        # canonical face passes through byte-identically.
        [/\bed[.\s]+(\d+(?:\.\d+)?)\b/i, 'ed\1'],
        # Bare trailing edition: fires only when a document number is already
        # present (a digit directly before the space — "ECMA 262 5.1"), so the
        # space-separator form itself ("ECMA 6") keeps its number: there the
        # char before the space is "A", not a digit. The match consumes that
        # one space and the replacement puts it back before the token. A
        # glued "vol2" has no space, and a spaced "vol 2" has no digit before
        # the space, so a volume number is never rewritten — the grammar's
        # ed-then-vol order is untouched.
        [/(\d) (\d+(?:\.\d+)?)\z/, '\1 ed\2'],
      ].freeze

      # Pre-parse ingestion normalization: map the human edition spellings
      # onto the glued token the grammar reads. Every rule rewrites INTO a
      # canonical face, so a string the grammar already accepts is returned
      # byte-identically and only new accepts are added.
      def self.normalize_input(string)
        EDITION_ALIASES.reduce(string) do |acc, (pattern, replacement)|
          acc.gsub(pattern, replacement)
        end
      end
    end
  end
end
