require "lutaml/model"
require_relative "../single_identifier"

module PubidNew
  module Cen
    module Identifiers
      class TechnicalSpecification < SingleIdentifier
        attribute :type, Components::Type, default: -> { type[:key] }

        TYPED_STAGES = [
          Components::TypedStage.new(
            code: :pubts,
            stage_code: :published,
            type_code: :ts,
            abbr: ["TS"],
            name: "Technical Specification",
            harmonized_stages: %w[60.00 60.60],
          ),
          Components::TypedStage.new(
            code: :prts,
            stage_code: :proposal,
            type_code: :ts,
            abbr: ["prTS"],
            name: "Proposal Technical Specification",
            harmonized_stages: %w[30.00 30.20 30.60 30.92 30.98 30.99],
          ),
        ].freeze

        def self.type
          { key: :ts, title: "Technical Specification", short: "TS" }
        end
      end
    end
  end
end