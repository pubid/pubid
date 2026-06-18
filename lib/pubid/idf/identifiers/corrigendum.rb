# frozen_string_literal: true

module Pubid
  module Idf
    module Identifiers
      class Corrigendum < SupplementIdentifier
        attribute :type, Components::Type, default: -> { self.class.type[:key] }

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
          { key: :cor,
            web: :corrigendum, title: "Corrigendum", short: "COR" }
        end
      end
    end
  end
end
