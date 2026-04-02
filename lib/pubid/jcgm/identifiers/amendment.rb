# frozen_string_literal: true

module Pubid
  module Jcgm
    module Identifiers
      class Amendment < SupplementIdentifier
        attribute :type, Pubid::Components::Type, default: -> { self.class.type[:key] }

        TYPED_STAGES = [
          Pubid::Components::TypedStage.new(
            code: :pubamd,
            stage_code: :published,
            type_code: :amendment,
            abbr: ["Amd"],
            name: "Amendment",
            harmonized_stages: %w[60.00 60.60],
          ),
        ].freeze

        def self.type
          { key: :amendment, title: "Amendment", short: "Amd" }
        end

        def to_s(lang: :en, lang_single: false, with_edition: false,
format: nil, stage_format_long: nil, with_date: nil)
          result = base_identifier.to_s if base_identifier
          result += "/Amd"
          result += " #{iteration.value}" if iteration
          result += ":#{date}" if date
          result
        end
      end
    end
  end
end
