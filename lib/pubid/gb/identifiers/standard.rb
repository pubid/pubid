# frozen_string_literal: true

module Pubid
  module Gb
    module Identifiers
      # The default Chinese Standard identifier type. The class name yields
      # the polymorphic _type tag "pubid:gb:standard".
      #
      # Examples:
      #   GB/T 20223-2006
      #   GB/T 5606.1-2004
      #   GB/T 5606 (all parts)
      #   JB/T 13368-2018
      #   T/GZAEPI 001—2018
      class Standard < Identifier
        TYPED_STAGES = [
          Pubid::Components::TypedStage.new(
            code: :pubgb,
            stage_code: :published,
            type_code: :gb,
            abbr: ["GB"],
            name: "Chinese Standard",
            harmonized_stages: %w[60.00 60.60],
          ),
        ].freeze

        def self.type
          { key: :gb, web: :chinese_standard, title: "Chinese Standard",
            short: "GB" }
        end
      end
    end
  end
end
