require_relative "stage"
require_relative "type"

module PubidNew
  module Components
    class TypedStage < Lutaml::Model::Serializable
      attribute :name, :string
      attribute :type_code, :string
      attribute :stage_code, :string
      attribute :abbr, :string, collection: true
      attribute :harmonized_stages, :string, collection: true

      def to_stage
        Stage.new(
          name: name,
          stage_code: stage_code,
          abbr: abbr.first,
          harmonized_stages: harmonized_stages
        )
      end

      def to_type
        Type.new(
          name: name,
          type_code: type_code,
          abbr: abbr.first
        )
      end

      def abbreviation
        abbr.first
      end

    end
  end
end
