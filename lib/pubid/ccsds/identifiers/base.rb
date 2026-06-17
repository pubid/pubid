# frozen_string_literal: true

module Pubid
  module Ccsds
    module Identifiers
      # CCSDS base identifier.
      #
      # Format: CCSDS NUMBER.PART-TYPE-EDITION[-SUFFIX][ - LANGUAGE Translated]
      # Examples: CCSDS 120.0-G-4, CCSDS 100.0-G-1-S, CCSDS 551.1-O-2 - Russian Translated
      #
      # CCSDS uses plain strings for `type` (book-color letter: B, G, M, R, Y, O),
      # `suffix`, and `language` (language name) because they are CCSDS-specific
      # semantics that do not map cleanly onto the shared Components model.
      class Base < ::Pubid::Identifier
        TYPED_STAGES = [
          Pubid::Components::TypedStage.new(
            abbr: [""],
            stage_code: "published",
            type_code: "base",
          ),
        ].freeze

        # CCSDS-specific attributes. `type` overrides the inherited
        # Components::Type because CCSDS uses single book-color letters
        # (B/G/M/R/Y/O) rather than the shared Type component.
        attribute :type, :string
        attribute :suffix, :string
        attribute :language, :string

        def self.type
          { key: :base, title: "Base Standard", short: nil }
        end

        def publisher
          "CCSDS"
        end

        def to_s(**_opts)
          result = "#{publisher} #{number}"
          result += ".#{part}" if part
          result += "-#{type}" if type
          result += "-#{edition}" if edition
          result += "-#{suffix}" if suffix
          result += " - #{language} Translated" if language
          result
        end
      end
    end
  end
end
