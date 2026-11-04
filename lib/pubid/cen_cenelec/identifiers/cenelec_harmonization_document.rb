# frozen_string_literal: true

require "lutaml/model"

module Pubid
  module CenCenelec
    module Identifiers
      class CenelecHarmonizationDocument < SingleIdentifier
        attribute :type, Components::Type, default: -> { self.class.default_type }

        TYPED_STAGES = [
          Components::TypedStage.new(
            code: :pubhd,
            stage_code: :published,
            type_code: :hd,
            abbr: ["HD"],
            name: "CENELEC Harmonization Document",
            harmonized_stages: %w[60.00 60.60],
          ),
        ].freeze

        # Its own key: CenCenelec.locate_type returns the first class with
        # a matching key, and HarmonizationDocument owns :hd ("HD 123:2020").
        # A shared key made the class choice depend on load order.
        def self.type
          { key: :chd, title: "CENELEC Harmonization Document", short: "HD" }
        end
      end
    end
  end
end
