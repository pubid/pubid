# frozen_string_literal: true

require "lutaml/model"

module Pubid
  module Jis
    module Components
      # Represents a JIS code with series letter, number, and optional parts.
      # Number and parts are stored as strings to preserve formatting such as
      # leading zeros ("0205"), mirroring Pubid::Iso::Components::Code. Being a
      # plain lutaml-model Serializable (no custom initialize) lets it
      # round-trip through to_hash/from_hash.
      # Examples:
      #   A 0001          => series: "A", number: "0001", parts: []
      #   B 0060-1        => series: "B", number: "0060", parts: ["1"]
      #   C 61000-3-2     => series: "C", number: "61000", parts: ["3", "2"]
      class Code < Lutaml::Model::Serializable
        attribute :series, :string    # Single letter A-Z
        attribute :number, :string    # Number; original formatting preserved
        attribute :parts, :string, collection: true # Optional multi-level parts

        # Render as "SERIES NUMBER[-PART[-SUBPART[...]]]"
        def to_s
          result = "#{series} #{number}"
          result += parts.map { |p| "-#{p}" }.join if parts&.any?
          result
        end

        def ==(other)
          return false unless other.is_a?(Code)

          series == other.series &&
            number == other.number &&
            (parts || []) == (other.parts || [])
        end
      end
    end
  end
end
