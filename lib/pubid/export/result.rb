# frozen_string_literal: true

module Pubid
  module Export
    # Immutable value object representing extracted metadata for one identifier type.
    # Encapsulates all data needed by the website for a single doc type entry.
    class IdentifierTypeResult
      attr_reader :key, :title, :short, :abbr, :typed_stages, :examples

      def initialize(key:, title:, short: nil, abbr: [], typed_stages: [], examples: [])
        @key = key.to_s
        @title = title
        @short = short
        @abbr = Array(abbr).map(&:to_s)
        @typed_stages = typed_stages.map { |ts| TypedStageResult.from_typed_stage(ts) }
        @examples = examples
        freeze
      end

      def to_h
        {
          key: @key,
          title: @title,
          short: @short,
          abbr: @abbr,
          typed_stages: @typed_stages.map(&:to_h),
          examples: @examples,
        }
      end
      alias to_hash to_h
    end

    # Immutable value object for a single typed stage.
    class TypedStageResult
      attr_reader :stage_code, :type_code, :abbr, :name, :harmonized_stages

      def initialize(stage_code:, type_code:, abbr:, name:, harmonized_stages:)
        @stage_code = stage_code.to_s
        @type_code = type_code.to_s
        @abbr = Array(abbr).map(&:to_s)
        @name = name
        @harmonized_stages = Array(harmonized_stages).map(&:to_s)
        freeze
      end

      def self.from_typed_stage(ts)
        new(
          stage_code: ts.stage_code,
          type_code: ts.type_code,
          abbr: ts.abbr,
          name: ts.is_a?(Components::TypedStage) ? ts.name : nil,
          harmonized_stages: ts.is_a?(Components::TypedStage) ? ts.harmonized_stages : [],
        )
      end

      def to_h
        {
          stage_code: @stage_code,
          type_code: @type_code,
          abbr: @abbr,
          name: @name,
          harmonized_stages: @harmonized_stages,
        }
      end
    end

    # Immutable value object for extracted flavor metadata.
    class FlavorResult
      attr_reader :flavor, :identifier_types, :wrapper_types, :attributes

      def initialize(flavor:, identifier_types:, wrapper_types: [], attributes: [])
        @flavor = flavor.to_s
        @identifier_types = identifier_types
        @wrapper_types = wrapper_types
        @attributes = attributes
        freeze
      end

      def to_h
        h = {
          identifier_types: @identifier_types.map(&:to_h),
          attributes: @attributes,
        }
        h[:wrapper_types] = @wrapper_types.map(&:to_h) unless @wrapper_types.empty?
        h
      end
      alias to_hash to_h
    end
  end
end
