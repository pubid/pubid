# frozen_string_literal: true

module Pubid
  module Bsi
    module Identifiers
      # AerospaceStandard handles BSI aerospace and specialized standards
      # with letter prefixes indicating domain categorization.
      #
      # Categorization includes:
      # - Aircraft (A, B, C, F, G, HC, L, S, SP, X)
      # - Methods related to aircraft (M)
      # - Marine (MA)
      # - Polyester (PL)
      # - Aerospace materials (TA for Titanium-Aluminium alloys)
      # - Automotive (AU)
      # - Multi-letter prefixes (2A, 2B, 2C, 2F, 2G, 2HC, 2HR, 2L, 2M, 2S, 2SP, 2TA, 2X, etc.)
      #
      # Examples:
      #   BS A 109:2024       # Aircraft (A prefix)
      #   BS AU 145e:2018     # Automotive (AU prefix) with letter suffix
      #   BS M 38:1971        # Methods (M prefix)
      #   BS 2A 293:2005      # Multi-letter prefix (2A)
      #   BS SP 113:1954      # Specification (SP prefix)
      #   BS TA 40:1971       # Titanium-Aluminium (TA prefix)
      class AerospaceStandard < SingleIdentifier
        attribute :prefix, :string

        # Single-letter aerospace/specialized prefixes
        SINGLE_LETTER_PREFIXES = %w[
          A B C F G L M S X
          AU HC MA PL QC SP TA
        ].freeze

        # Multi-letter prefixes (number + letter combination)
        MULTI_LETTER_PREFIXES = %w[
          2A 2B 2C 2F 2G 2HC 2HR 2L 2M 2S 2SP 2TA 2X
          3A 3B 3F 3G 3HR 3J 3L 3S 3TA
          4F 4L 4S
          5S 7S
        ].freeze

        ALL_PREFIXES = (SINGLE_LETTER_PREFIXES + MULTI_LETTER_PREFIXES).freeze

        # TYPED_STAGES for aerospace standards (published by default)
        TYPED_STAGES = [
          Pubid::Components::TypedStage.new(
            code: :pubas,
            stage_code: :published,
            type_code: :aerospace,
            abbr: ["BS"],
            name: "Aerospace/Specialized Standard",
            harmonized_stages: %w[60.00 60.60],
          ),
        ].freeze

        def self.type
          { key: :aerospace, title: "Aerospace/Specialized Standard",
            short: "BS" }
        end

        def to_s(lang: :en, lang_single: false)
          render(format: :human, lang: lang, lang_single: lang_single)
        end
      end
    end
  end
end
