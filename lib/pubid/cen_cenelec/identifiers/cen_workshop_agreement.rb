require "lutaml/model"
# frozen_string_literal: true

module Pubid
  module CenCenelec
    module Identifiers
      class CenWorkshopAgreement < SingleIdentifier
        attribute :type, Components::Type, default: -> { self.class.type[:key] }

        TYPED_STAGES = [
          Components::TypedStage.new(
            code: :pubcwa,
            stage_code: :published,
            type_code: :cwa,
            abbr: ["CWA"],
            name: "CEN Workshop Agreement",
            harmonized_stages: %w[60.00 60.60],
          ),
        ].freeze

        def self.type
          { key: :cwa, title: "CEN Workshop Agreement", short: "CWA" }
        end
      end
    end
  end
end
