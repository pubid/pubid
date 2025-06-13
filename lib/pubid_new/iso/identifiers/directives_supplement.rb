require_relative "../supplement_identifier"
require_relative "../../components/typed_stage"

module PubidNew
  module Iso
    module Identifiers
      class DirectivesSupplement < SupplementIdentifier
        attribute :type, Components::Type, default: -> { type[:key] }

        TYPED_STAGES = [
          Components::TypedStage.new(
            code: :pubdirsup,
            stage_code: :published,
            type_code: :dirsup,
            abbr: ["SUP", "Supplement"],
            name: "Supplement",
            harmonized_stages: %w[60.00 60.60],
          ),
        ].freeze

        def self.type
          { key: :dirsup, title: "Directives Supplement", short: "SUP" }
        end

        # def render_directives_supplement_identifier(identifier)
        #   raise "Not a directives supplement identifier" unless identifier.is_a?(Identifiers::DirectivesSupplement)

        #   render(identifier.base_identifier) +
        #     " #{identifier.publisher.body}" +
        #     " #{identifier.stage.abbr}" +
        #     (identifier.date ? ":#{identifier.date.year}" : "")
        # end

        def to_s(lang: :en, lang_single: false)
          [
            base_identifier.to_s(lang: lang, lang_single: lang_single),
            " #{publisher.body}",
            " #{typed_stage.abbreviation}",
            (date ? ":#{date.year}" : "")
          ].join('')
        end
      end
    end
  end
end