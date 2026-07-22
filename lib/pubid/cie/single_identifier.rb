# frozen_string_literal: true

module Pubid
  module Cie
    # Base class for single CIE identifiers (standards, conferences, etc.)
    # Single Responsibility: Provide common attributes for base documents
    #
    # Single identifiers are base documents that can exist independently,
    # as opposed to supplement identifiers (amendments, corrigenda) which
    # modify a base identifier.
    #
    # Classes inheriting from SingleIdentifier:
    # - Standard (common CIE publications)
    # - Conference (conference proceedings)
    # - Bundle (bundles of multiple identifiers)
    # - JointPublished (co-published with ISO/IEC)
    # - DualPublished (dual published with IEC)
    # - Identical (identical to ISO publications)
    # - TutorialBundle (tutorial bundles)
    class SingleIdentifier < Identifier
      # Stored as a plain string (always "CIE") so it round-trips through
      # to_hash/from_hash. Was a `def publisher` method, which made lutaml
      # serialize a String against the Components::Publisher attribute and raise.
      attribute :publisher, :string, default: -> { "CIE" }

      attribute :year, :string
      # The number<->year separator character, derived from +style+ (the sole
      # separator field; there is no date_separator attribute):
      #   current -> ":"   legacy -> "-"   slash -> "/"
      def date_sep_char
        { "legacy" => "-", "slash" => "/" }.fetch(style, ":")
      end

      # Partial-reference matching: CIE keeps the publication year in its own
      # `year` string attribute (the separator lives in `style`), not a `Date`
      # component, so the base's `:year`->`:date` remap would nil the unused
      # inherited `date` and leave `year` intact. Call super (preserving the
      # nested-identifier recursion), then nil `year` directly so a year-less
      # CIE ref is a year wildcard under `matches?(ignore: [:year])`.
      #
      # Known limit: `style` (which also encodes the era: current<->colon,
      # legacy<->dash) is intentionally NOT wildcarded, so bare `CIE 015`
      # (always current) matches a colon-dated full but not a legacy dash-dated
      # (pre-2001) one. Partial-ref scope targets modern colon forms.
      def exclude(*args)
        result = super
        result.year = nil if args.include?(:year) || args.include?(:date)
        result
      end

      # CIE stores its publication year in its own `year` string attribute
      # (not a Components::Date), and uses a single-Language component with
      # multiple formats. Override the lossless MR template so `CIE S 017/E:2011`
      # round-trips as `CIE.S.017.E.2011` rather than losing the type letter,
      # language, and year (issue #142). Subclasses add the `s_prefix` and
      # `language` attributes that this template reads.
      def mr_year
        year&.to_s
      end

      def mr_languages
        return nil unless respond_to?(:language) && language

        "/#{language.code}"
      end
    end
  end
end
