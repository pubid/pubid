# frozen_string_literal: true

module Pubid
  module Omg
    module Identifiers
      # OMG specification identifier.
      #
      # Examples:
      #   OMG AMI4CCM 1.0
      #   OMG UML 2.5.1
      #   OMG DDS 5 beta 3
      #   OMG CORBA
      class Specification < Identifier
        TYPED_STAGES = [
          Pubid::Components::TypedStage.new(
            code: :pubomg,
            stage_code: :published,
            type_code: :omg,
            abbr: ["OMG"],
            name: "OMG Specification",
            harmonized_stages: %w[60.00 60.60],
          ),
        ].freeze

        def self.type
          { key: :omg, web: :specification, title: "OMG Specification",
            short: "OMG" }
        end
      end
    end
  end
end
