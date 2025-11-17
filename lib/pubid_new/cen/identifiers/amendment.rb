require "lutaml/model"
require_relative "../supplement_identifier"

module PubidNew
  module Cen
    module Identifiers
      class Amendment < SupplementIdentifier
        attribute :type, Components::Type, default: -> { type[:key] }

        TYPED_STAGES = [
          Components::TypedStage.new(
            code: :pubamd,
            stage_code: :published,
            type_code: :amd,
            abbr: ["A"],
            name: "Amendment",
            harmonized_stages: %w[60.00 60.60],
          ),
        ].freeze

        def self.type
          { key: :amd, title: "Amendment", short: "A" }
        end

        def to_s(lang: :en, lang_single: false)
          supplement_parts = []
          supplement_parts << "A"
          supplement_parts << number.value if number
          
          supplement_str = supplement_parts.join
          supplement_str += ":#{date.year}" if date
          
          # If we have a base_identifier, render as slash supplement
          # Otherwise, render as standalone (for bundled identifiers)
          if base_identifier
            "#{base_identifier.to_s(lang: lang, lang_single: lang_single)}/#{supplement_str}"
          else
            supplement_str
          end
        end
      end
    end
  end
end