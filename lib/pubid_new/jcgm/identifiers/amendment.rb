# frozen_string_literal: true

require_relative "../supplement_identifier"
require_relative "../../components/typed_stage"
require_relative "../../components/type"

module PubidNew
  module Jcgm
    module Identifiers
      class Amendment < SupplementIdentifier
        attribute :type, PubidNew::Components::Type, default: -> { type[:key] }

        TYPED_STAGES = [
          PubidNew::Components::TypedStage.new(
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

        def to_s(lang: :en, lang_single: false, with_edition: false, format: nil, stage_format_long: nil, with_date: nil)
          result = base_identifier.to_s if base_identifier
          result += "/Amd"
          result += " #{iteration.value}" if iteration
          result += ":#{date.to_s}" if date
          result
        end
      end
    end
  end
end