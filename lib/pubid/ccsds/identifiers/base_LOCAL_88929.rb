# frozen_string_literal: true

require "lutaml/model"

module Pubid
  module Ccsds
    module Identifiers
      # CCSDS identifier
      # Format: CCSDS NUMBER.PART-TYPE-EDITION[-SUFFIX]
      # Example: CCSDS 120.0-G-4, CCSDS 100.0-G-1-S
      class Base < Lutaml::Model::Serializable
        attribute :number, :string
        attribute :part, :string
        attribute :type, :string # B, G, M, R, Y, O, etc.
        attribute :edition, :string
        attribute :suffix, :string # Optional suffix like -S
        attribute :language, :string # Language metadata (e.g., "French", "Russian")

        def publisher
          "CCSDS"
        end

        def to_s
          result = "#{publisher} #{number}"
          result += ".#{part}" if part
          result += "-#{type}" if type
          result += "-#{edition}" if edition
          result += "-#{suffix}" if suffix

          # Add language metadata
          result += " - #{language} Translated" if language

          result
        end

        def ==(other)
          return false unless other.is_a?(Base)

          number == other.number &&
            part == other.part &&
            type == other.type &&
            edition == other.edition &&
            suffix == other.suffix &&
            language == other.language
        end
      end
    end
  end
end
