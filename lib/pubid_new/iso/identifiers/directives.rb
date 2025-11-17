require_relative "../single_identifier"
require_relative "../../components/typed_stage"

module PubidNew
  module Iso
    module Identifiers
      class Directives < SingleIdentifier
        attribute :type, Components::Type, default: -> { type[:key] }
        attribute :subgroup, Components::Code

        TYPED_STAGES = [
          Components::TypedStage.new(
            code: :pubguide,
            stage_code: :published,
            type_code: :dir,
            abbr: ["DIR", "Directives Part", "Directives, Part", "Directives,",
                  "Directives"],
            name: "Directives",
            harmonized_stages: %w[60.00 60.60],
          ),
        ].freeze

        def self.type
          { key: :dir, title: "Directives", short: "DIR" }
        end

        def publisher_portion(lang: :en)
          return [
              publisher.body,
              (subgroup ? " #{subgroup.value}" : ""),
              (typed_stage.abbreviation.empty? ? "" : " #{typed_stage.abbreviation}"),
            ].join('') unless copublishers&.any?

          # If there are copublishers, join them with slashes
          [
            ([publisher] + copublishers).map(&:body).join("/"),
            (subgroup ? " #{subgroup.value}" : ""),
            (typed_stage.abbreviation.empty? ? "" : " #{typed_stage.abbreviation}"),
          ].join('')
        end

        # This differs from the basic number_portion in that directives may have
        # a variant (ISO or IEC) after the number rendered as a part but
        # separated by a space.
        def number_portion(lang_single: false)
          result = [
            # Directives may not have a number
            (number ? "#{number.value}" : ""),

            # Parts and subparts are optional
            (part ? " #{part.value}" : ""),
            (subpart ? "-#{subpart.value}" : ""),

            # Stage iteration is optional
            (stage_iteration ? ".#{stage_iteration.value}" : ""),

            # Date is optional
            (date ? ":#{date.year}" : ""),
          ].join('')

          # Return nil if there's nothing to render
          result.empty? ? nil : result
        end

        # def to_s(lang: :en, lang_single: false, with_edition: false)
        #   [].tap do |parts|
        #     parts << publisher_portion(lang: lang)
        #     parts << number_portion(lang_single: lang_single)
        #     parts << edition_portion(lang: lang) if with_edition
        #   end.compact.join(' ').tap do |s|
        #     s << language_portion(lang_single: lang_single) if languages&.any?
        #   end
        # end
      end
    end
  end
end