# frozen_string_literal: true

require "lutaml/model"
require_relative "../single_identifier"

module PubidNew
  module Cen
    module Identifiers
      class EuropeanSpecification < SingleIdentifier
        attribute :type, Components::Type, default: -> { type[:key] }

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
          { key: :es, title: "European Specification", short: "ES" }
        end
      end
    end
  end
end