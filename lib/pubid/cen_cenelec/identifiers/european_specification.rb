# frozen_string_literal: true

require "lutaml/model"

module Pubid
  module CenCenelec
    module Identifiers
      class EuropeanSpecification < SingleIdentifier
        attribute :type, Components::Type, default: -> { self.class.type[:key] }

        TYPED_STAGES = [
          Components::TypedStage.new(
            code: :pubes,
            stage_code: :published,
            type_code: :es,
            abbr: ["ES"],
            name: "European Specification",
            harmonized_stages: %w[60.00 60.60],
          ),
        ].freeze

        def self.type
          { key: :es,
            web: :european_specification, title: "European Specification", short: "ES" }
        end
      end
    end
  end
end
