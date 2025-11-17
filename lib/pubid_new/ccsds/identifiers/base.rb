require "lutaml/model"
require_relative "../single_identifier"

module PubidNew
  module Ccsds
    module Identifiers
      class Base < SingleIdentifier
        attribute :type, Components::Type, default: -> { type[:key] }

        TYPED_STAGES = [
          Components::TypedStage.new(
            code: :pubccsds,
            stage_code: :published,
            type_code: :ccsds,
            abbr: [""],
            name: "CCSDS Standard",
            harmonized_stages: %w[60.00 60.60],
          ),
        ].freeze

        def self.type
          { key: :ccsds, title: "CCSDS Standard", short: "" }
        end
      end
    end
  end
end