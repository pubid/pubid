# frozen_string_literal: true

require "lutaml/model"
require_relative "../single_identifier"

module PubidNew
  module Cen
    module Identifiers
      class CenReport < SingleIdentifier
        attribute :type, Components::Type, default: -> { self.class.type[:key] }

        TYPED_STAGES = [
          Components::TypedStage.new(
            code: :pubcr,
            stage_code: :published,
            type_code: :cr,
            abbr: ["CR"],
            name: "CEN Report",
            harmonized_stages: %w[60.00 60.60],
          ),
        ].freeze

        def self.type
          { key: :cr, title: "CEN Report", short: "CR" }
        end
      end
    end
  end
end
