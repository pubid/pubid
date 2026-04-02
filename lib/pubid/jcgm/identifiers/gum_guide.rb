# frozen_string_literal: true

module Pubid
  module Jcgm
    module Identifiers
      class GumGuide < SingleIdentifier
        attribute :gum_number, Pubid::Components::Code
        attribute :type, Pubid::Components::Type, default: -> { self.class.type[:key] }

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

        def to_s(lang: :en, lang_single: false, with_edition: false,
format: nil, stage_format_long: nil, with_date: nil)
          parts = []
          parts << publisher.publisher if publisher
          parts << "GUM-#{gum_number.value}" if gum_number

          result = parts.join(" ")
          result += ":#{date}" if date
          result += language_portion if languages&.any?
          result
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
