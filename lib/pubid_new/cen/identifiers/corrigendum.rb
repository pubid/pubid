require "lutaml/model"
require_relative "../supplement_identifier"

module PubidNew
  module Cen
    module Identifiers
      class Corrigendum < SupplementIdentifier
        attribute :type, Components::Type, default: -> { type[:key] }

        TYPED_STAGES = [
          Components::TypedStage.new(
            code: :pubcor,
            stage_code: :published,
            type_code: :cor,
            abbr: ["AC"],
            name: "Corrigendum",
            harmonized_stages: %w[60.00 60.60],
          ),
        ].freeze

        def self.type
          { key: :cor, title: "Corrigendum", short: "AC" }
        end

        def to_s(lang: :en, lang_single: false)
          supplement_parts = []
          supplement_parts << "AC"
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