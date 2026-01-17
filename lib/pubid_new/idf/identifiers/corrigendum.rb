require_relative "../supplement_identifier"
# frozen_string_literal: true
require_relative "../../components/typed_stage"

module PubidNew
  module Idf
    module Identifiers
      class Corrigendum < SupplementIdentifier
        attribute :type, Components::Type, default: -> { type[:key] }

        TYPED_STAGES = [
          Components::TypedStage.new(
            code: :published,
            abbr: ["COR"],
            short_abbr: "COR",
            long_abbr: "COR",
            type_code: :cor,
            stage_code: :published,
            name: "Corrigendum",
          ),
        ].freeze

        def self.type
          { key: :cor, title: "Corrigendum", short: "COR" }
        end
      end
    end
  end
end
