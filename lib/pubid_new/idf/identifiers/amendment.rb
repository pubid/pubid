require_relative "../identifier"
require_relative "../../components/typed_stage"

module PubidNew
  module Idf
  module Identifiers
    class Amendment < Identifier
      attribute :type, Components::Type, default: -> { type[:key] }
      attribute :base_identifier, Identifier

      TYPED_STAGES = [
        Components::TypedStage.new(
          code: :published,
          abbr: ["AMD"],
          short_abbr: "AMD",
          long_abbr: "AMD",
          type_code: :amd,
          stage_code: :published,
          name: "Amendment",
        ),
      ].freeze

      def self.type
        { key: :amd, title: "Amendment", short: "AMD" }
      end

      def to_s(lang: :en, lang_single: false, with_edition: false)
        [
          base_identifier.to_s(lang: lang, lang_single: lang_single, with_edition: with_edition),
          "/",
          typed_stage.abbreviation,
          " ",
          number.value,
          (date ? ":#{date.year}" : "")
        ].join('')
      end
    end
  end
end
end