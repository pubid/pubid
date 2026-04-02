# frozen_string_literal: true

require "lutaml/model"
require_relative "../../serializable"
require_relative "../urn_generator"

module Pubid
  module Ccsds
    module Identifiers
      # CCSDS identifier
      # Format: CCSDS NUMBER.PART-TYPE-EDITION[-SUFFIX]
      # Example: CCSDS 120.0-G-4, CCSDS 100.0-G-1-S
      class Base < Lutaml::Model::Serializable
        include Pubid::Serializable

        # CCSDS uses a simple architecture without typed stages
        # TYPED_STAGES includes default stage for base identifiers
        TYPED_STAGES = [
          Pubid::Components::TypedStage.new(
            abbr: [""],
            stage_code: "published",
            type_code: "base"
          ),
        ].freeze

        # Type information for this identifier class
        #
        # @return [Hash] Type information with key, title, and short form
        def self.type
          { key: :base, title: "Base Standard", short: nil }
        end

        # Generate URN for this identifier
        #
        # @return [String] URN representation
        def to_urn
          UrnGenerator.new(self).generate
        end

        # Include CCSDS-specific attributes in serialization
        def base_hash
          hash = super
          # CCSDS uses plain strings for type, edition, suffix
          hash[:type] = type if type
          hash[:suffix] = suffix if suffix
          hash[:language] = language if language
          hash
        end

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
