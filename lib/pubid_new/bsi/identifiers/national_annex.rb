# frozen_string_literal: true

require_relative "../single_identifier"

module PubidNew
  module Bsi
    module Identifiers
      # National Annex (NA) identifier
      # Can have own supplements: "NA+A1:2012 to BASE"
      class NationalAnnex < SingleIdentifier
        attribute :na_supplements, Base, polymorphic: true, collection: true  # Supplements on the NA itself
        attribute :base_doc, Base, polymorphic: true  # The identifier after "to"

        TYPED_STAGES = [
          PubidNew::Components::TypedStage.new(
            code: :pubna,
            stage_code: :published,
            type_code: :na,
            abbr: ["NA"],
            name: "National Annex",
            harmonized_stages: %w[60.00 60.60],
          ),
        ].freeze

        def self.type
          { key: :na, title: "National Annex", short: "NA" }
        end

        # Delegation methods to access wrapped base_doc attributes
        def number
          base_doc&.number || super
        end

        def date
          base_doc&.date || super
        end

        def part
          base_doc&.part || super
        end

        def subpart
          base_doc&.subpart || super
        end

        def to_s(lang: :en, lang_single: false)
          result = "NA"

          # Add NA supplements if present
          if na_supplements && na_supplements.any?
            na_supplements.each do |supp|
              if supp.is_a?(Amendment)
                result += "+A#{supp.amendment_number}:#{supp.amendment_year}"
              elsif supp.is_a?(Corrigendum)
                result += "+C#{supp.corrigendum_number}:#{supp.corrigendum_year}"
              end
            end
          end

          result += " to "

          # Render the base identifier (what this NA is for)
          if base_doc
            result += base_doc.to_s
          else
            # Fallback to parent rendering
            result += super
          end

          result
        end
      end
    end
  end
end