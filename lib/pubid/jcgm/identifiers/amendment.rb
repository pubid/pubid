# frozen_string_literal: true

module Pubid
  module Jcgm
    module Identifiers
      class Amendment < SupplementIdentifier
        attribute :type, Pubid::Components::Type, default: -> { self.class.type[:key] }

        TYPED_STAGES = [
          Pubid::Components::TypedStage.new(
            code: :pubamd,
            stage_code: :published,
            type_code: :amendment,
            abbr: ["Amd"],
            name: "Amendment",
            harmonized_stages: %w[60.00 60.60],
          ),
        ].freeze

        def self.type
          { key: :amendment, title: "Amendment", short: "Amd" }
        end
      end
    end
  end
end
