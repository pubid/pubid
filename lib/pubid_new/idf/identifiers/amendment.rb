require_relative "../supplement_identifier"
# frozen_string_literal: true
require_relative "../../components/typed_stage"

module PubidNew
  module Idf
    module Identifiers
      class Amendment < SupplementIdentifier
        attribute :type, Components::Type, default: -> { self.class.type[:key] }

        TYPED_STAGES = [
          Components::TypedStage.new(
            code: :published,
            abbr: ["AMD"],
            short_abbr: "AMD",
            long_abbr: "AMD",
            type_code: :amd,
            stage_code: :published,
            name: "Amendment",
          ),
        ].freeze

        def self.type
          { key: :amd, title: "Amendment", short: "AMD" }
        end
      end
    end
  end
end
