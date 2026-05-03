require "lutaml/model"
# frozen_string_literal: true

module Pubid
  module CenCenelec
    module Identifiers
      class HarmonizationDocument < SingleIdentifier
        attribute :type, Components::Type, default: -> { self.class.type[:key] }

        TYPED_STAGES = [
          Components::TypedStage.new(
            code: :pubhd,
            stage_code: :published,
            type_code: :hd,
            abbr: ["HD"],
            name: "Harmonization Document",
            harmonized_stages: %w[60.00 60.60],
          ),
        ].freeze

        def self.type
          { key: :hd, title: "Harmonization Document", short: "HD" }
        end
      end
    end
  end
end
