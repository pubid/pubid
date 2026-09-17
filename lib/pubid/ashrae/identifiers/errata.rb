# frozen_string_literal: true

require "lutaml/model"

module Pubid
  module Ashrae
    module Identifiers
      # Errata identifier for ASHRAE standards and guidelines
      # Represents corrections/errata for a base standard
      # Examples:
      # - ASHRAE Guideline 0-2005 Errata (September 28, 2011)
      # - ANSI/ASHRAE Standard 62.1-2004 Errata (May 4, 2007)
      class Errata < SupplementIdentifier
        # The date of the erratum lives in the `date` component this class
        # inherits from ::Pubid::Identifier. A flavor-named second attribute
        # (the old `errata_date` :string) described the same value under a
        # name no shared code reads — the GB lesson in CLAUDE.md. The base
        # standard keeps its own edition year in `base.year`.

        # Make Renderers::MrString recurse into `base` instead of slugging the
        # supplement flat off attributes it does not have. Without it every
        # erratum of every standard shared one filename, and `to_slug` is what
        # consumers use as an output filename.
        def mr_supplement_suffix
          ["errata", mr_sanitize(date_slug)]
            .compact.reject(&:empty?).join(".")
        end

        # The sortable form of the date, for the slug only: "2008-10-10", or
        # "08-27" for the one shape that carries no year.
        def date_slug
          return nil unless date

          [date.year, date.month, date.day].compact.join("-")
        end

        TYPED_STAGES = [
          Components::TypedStage.new(
            abbr: ["Errata"],
            type_code: "errata",
            stage_code: "published",
          ),
        ].freeze

        def self.type
          { key: :errata, title: "ASHRAE Errata", short: "Errata" }
        end
      end
    end
  end
end
