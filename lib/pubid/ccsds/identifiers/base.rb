# frozen_string_literal: true

module Pubid
  module Ccsds
    module Identifiers
      # CCSDS base identifier (a published standard).
      #
      # Format: CCSDS NUMBER.PART-TYPE-EDITION[-SUFFIX][ - LANGUAGE Translated]
      # Examples: CCSDS 120.0-G-4, CCSDS 100.0-G-1-S, CCSDS 551.1-O-2 - Russian Translated
      #
      # Attributes, the key_value mapping and from_hash dispatch live on the
      # abstract root Pubid::Ccsds::Identifier; this concrete type only carries
      # its typed stage and rendering.
      class Base < Pubid::Ccsds::Identifier
        TYPED_STAGES = [
          Pubid::Components::TypedStage.new(
            abbr: [""],
            stage_code: "published",
            type_code: "base",
          ),
        ].freeze

        def self.type
          { key: :base, web: :base, title: "Base Standard", short: nil }
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
