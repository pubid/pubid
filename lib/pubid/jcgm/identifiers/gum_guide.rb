# frozen_string_literal: true

module Pubid
  module Jcgm
    module Identifiers
      # A GUM guide, e.g. "JCGM GUM-6:2020". The GUM-series part number ("6")
      # lives in the inherited `number` attribute (serialized as `number: "6"`);
      # `_type: pubid:jcgm:gum-guide` disambiguates it from a plain guide.
      class GumGuide < SingleIdentifier
        TYPED_STAGES = [
          Pubid::Components::TypedStage.new(
            code: :pubgumguide,
            stage_code: :published,
            type_code: :gum_guide,
            abbr: [""],
            name: "GUM Guide",
            harmonized_stages: %w[60.00 60.60],
          ),
        ].freeze

        def self.type
          { key: :gum_guide, title: "GUM Guide", short: "GUM" }
        end

        private

        def language_portion
          return "" unless languages&.any?

          codes = languages.map do |lang|
            lang.original_code || lang.code
          end

          "(#{codes.join('/')})"
        end
      end
    end
  end
end
