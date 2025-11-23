require_relative "../supplement_identifier"
require_relative "../../components/typed_stage"

module PubidNew
  module Iso
    module Identifiers
      class DirectivesSupplement < SupplementIdentifier
        attribute :type, ::PubidNew::Components::Type, default: -> {
          type[:key]
        }
        attribute :supplement_publisher, ::PubidNew::Components::Publisher

        # Delegate base identifier attributes for easier access
        def copublishers
          base_identifier&.copublishers
        end

        def publisher
          base_identifier&.publisher
        end

        TYPED_STAGES = [
          ::PubidNew::Components::TypedStage.new(
            code: :pubdirsup,
            stage_code: :published,
            type_code: :"dir-sup",
            abbr: ["DIR SUP", "SUP", "Supplement"],
            name: "Directives Supplement",
            harmonized_stages: %w[60.00 60.60],
          ),
        ].freeze

        def self.type
          { key: :"dir-sup", title: "Directives Supplement", short: "SUP" }
        end

        # def render_directives_supplement_identifier(identifier)
        #   raise "Not a directives supplement identifier" unless identifier.is_a?(Identifiers::DirectivesSupplement)

        #   render(identifier.base_identifier) +
        #     " #{identifier.publisher.body}" +
        #     " #{identifier.stage.abbr}" +
        #     (identifier.date ? ":#{identifier.date.year}" : "")
        # end

        def to_s(lang: :en, lang_single: false)
          if base_identifier
            # Full rendering with base identifier
            supp_pub_str = supplement_publisher ? " #{supplement_publisher}" : ""
            [
              base_identifier.to_s(lang: lang, lang_single: lang_single),
              supp_pub_str,
              " SUP", # Always render as "SUP" even though typed_stage.abbreviation is "DIR SUP"
              (date ? ":#{date.year}" : ""),
            ].join
          else
            # Simplified rendering for bundled identifiers (just the supplement part)
            to_supplement_s(lang: lang, lang_single: lang_single)
          end
        end

        # Render just the supplement part (for use in bundled identifiers)
        def to_supplement_s(lang: :en, lang_single: false)
          date_str = if date
                       month_part = date.month ? "-#{date.month}" : ""
                       ":#{date.year}#{month_part}"
                     else
                       ""
                     end

          supp_pub_str = supplement_publisher ? supplement_publisher.to_s : ""
          [
            supp_pub_str,
            " SUP",
            date_str,
          ].join
        end
      end
    end
  end
end
