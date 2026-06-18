# frozen_string_literal: true

module Pubid
  module Components
    # TypedStage component (combined stage + type, e.g. "DTR", "FDIS")
    #
    # Human render: typed-stage abbreviation with flavor-specific separator.
    # URN render: stage code (RFC 5141-bis: stage-XX.XX format handled by urn_generator).
    class TypedStage < Lutaml::Model::Serializable
      attribute :name, :string
      attribute :code, :string
      attribute :type_code, :string
      attribute :stage_code, :string
      attribute :abbr, :string, collection: true
      attribute :harmonized_stages, :string, collection: true
      attribute :original_abbr, :string
      attribute :short_abbr, :string
      attribute :long_abbr, :string

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

      def render(context: nil)
        return code.to_s if context&.urn? && code

        abbreviation(format_long: context&.stage_format_long || false)
      end

      def abbreviation(format_long: true)
        if format_long && long_abbr
          long_abbr
        elsif !format_long && short_abbr
          short_abbr
        else
          abbr.first
        end
      end

      def canonical_abbreviation
        abbr.first
      end
    end
  end
end
