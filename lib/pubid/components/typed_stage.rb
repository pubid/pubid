require_relative "stage"
# frozen_string_literal: true
require_relative "type"

module Pubid
  module Components
    class TypedStage < Lutaml::Model::Serializable
      attribute :name, :string
      attribute :type_code, :string
      attribute :stage_code, :string
      attribute :abbr, :string, collection: true
      attribute :harmonized_stages, :string, collection: true
      attribute :original_abbr, :string # Store the actual parsed abbreviation
      attribute :short_abbr, :string  # Short form: DAM, COR, FDAM
      attribute :long_abbr, :string   # Long form: DAmd, Cor, FDAmd

      def to_stage
        Stage.new(
          name: name,
          stage_code: stage_code,
          abbr: abbr.first,
          harmonized_stages: harmonized_stages,
        )
      end

      def to_type
        Type.new(
          name: name,
          type_code: type_code,
          abbr: abbr.first,
        )
      end

      def abbreviation(format_long: true)
        # Use format preference
        if format_long && long_abbr
          long_abbr
        elsif !format_long && short_abbr
          short_abbr
        else
          abbr.first # Fallback to canonical
        end
      end

      # Returns the canonical (normalized) abbreviation, always abbr.first
      def canonical_abbreviation
        abbr.first
      end
    end
  end
end
