# frozen_string_literal: true

module PubidNew
  module Bsi
    module Identifiers
      # SpecializedStandard handles BSI standards with special letter prefixes
      # that indicate domain-specific categorization (Aerospace, Automotive, Materials, etc.)
      #
      # Examples:
      #   BS A 16:1939        # Aircraft - General (A prefix)
      #   BS AU 177a:1980     # Automotive (AU prefix)
      #   BS C 10:1958        # Aircraft (C prefix)
      #   BS M 38:1971        # Methods - Aircraft (M prefix)
      #   BS 2A 241:2005      # Multi-letter prefix (2A)
      class SpecializedStandard < SingleIdentifier
        attribute :prefix, :string

        # Prefix categories for documentation
        # Single-letter prefixes
        AEROSPACE_PREFIXES = %w[A S L C G F X M].freeze
        AUTOMOTIVE_PREFIXES = %w[AU].freeze
        MATERIAL_PREFIXES = %w[TA MA PL B].freeze
        QUALITY_PREFIXES = %w[QC].freeze
        SPECIALIZED_PREFIXES = %w[HC].freeze

        # Multi-letter prefixes (number + letter combination)
        MULTI_LETTER_PREFIXES = %w[
          2A 2B 2C 2F 2G 2HC 2HR 2L 2M 2S 2SP 2TA
          3B 3F 3G 3HR 3J 3L 3S 3TA
          4F 4L 4S
          5S 7S
        ].freeze

        ALL_PREFIXES = (
          AEROSPACE_PREFIXES + AUTOMOTIVE_PREFIXES +
          MATERIAL_PREFIXES + QUALITY_PREFIXES +
          SPECIALIZED_PREFIXES + MULTI_LETTER_PREFIXES
        ).freeze

        def to_s
          parts = []
          parts << publisher.body if publisher
          parts << prefix if prefix
          parts << number.value if number
          parts << "-#{part.value}" if part
          parts << "-#{subpart.value}" if subpart
          parts << ":#{date.year}" if date
          parts << supplements_portion if respond_to?(:supplements_portion) && supplements_portion
          parts.join(" ")  # Space separators
        end
      end
    end
  end
end