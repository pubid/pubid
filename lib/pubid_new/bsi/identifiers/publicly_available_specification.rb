# frozen_string_literal: true

require_relative "../single_identifier.rb"

module PubidNew
  module Bsi
    module Identifiers
      # Publicly Available Specification (PAS) identifier
      class PubliclyAvailableSpecification < SingleIdentifier
        TYPED_STAGES = [
          PubidNew::Components::TypedStage.new(
            code: :pubpas,
            stage_code: :published,
            type_code: :pas,
            abbr: ["PAS"],
            name: "Publicly Available Specification",
            harmonized_stages: %w[60.00 60.60],
          ),
        ].freeze

        def self.type
          { key: :pas, title: "Publicly Available Specification", short: "PAS" }
        end
      end
    end
  end
end