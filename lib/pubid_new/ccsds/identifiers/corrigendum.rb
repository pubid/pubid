require "lutaml/model"
require_relative "../supplement_identifier"

module PubidNew
  module Ccsds
    module Identifiers
      class Corrigendum < SupplementIdentifier
        attribute :type, Components::Type, default: -> { type[:key] }

        TYPED_STAGES = [
          Components::TypedStage.new(
            code: :pubcor,
            stage_code: :published,
            type_code: :cor,
            abbr: ["Cor."],
            name: "Corrigendum",
            harmonized_stages: %w[60.00 60.60],
          ),
        ].freeze

        def self.type
          { key: :cor, title: "Corrigendum", short: "Cor." }
        end

        def to_s(lang: :en, lang_single: false)
          base_str = base_identifier.to_s(lang: lang, lang_single: lang_single)
          "#{base_str} Cor. #{number.value}"
        end
      end
    end
  end
end