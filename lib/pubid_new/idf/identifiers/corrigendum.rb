require_relative "../identifier"
require_relative "../../components/typed_stage"

module PubidNew
  module Idf
    module Identifiers
      class Corrigendum < Identifier
        attribute :type, Components::Type, default: -> { type[:key] }
        attribute :base_identifier, Identifier

        TYPED_STAGES = [
          Components::TypedStage.new(
            code: :published,
            abbr: ["COR"],
            short_abbr: "COR",
            long_abbr: "COR",
            type_code: :cor,
            stage_code: :published,
            name: "Corrigendum",
          ),
        ].freeze

        def self.type
          { key: :cor, title: "Corrigendum", short: "COR" }
        end

        def to_s(lang: :en, lang_single: false, with_edition: false)
          [
            base_identifier.to_s(lang: lang, lang_single: lang_single,
                                 with_edition: with_edition),
            "/",
            typed_stage.abbreviation,
            " ",
            number.value,
            (date ? ":#{date.year}" : ""),
          ].join("")
        end
      end
    end
  end
end
