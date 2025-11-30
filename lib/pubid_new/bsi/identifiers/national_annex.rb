# frozen_string_literal: true

require_relative "../single_identifier"

module PubidNew
  module Bsi
    module Identifiers
      # National Annex (NA) identifier
      class NationalAnnex < SingleIdentifier
        TYPED_STAGES = [
          Components::TypedStage.new(
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
        
        def to_s(lang: :en, lang_single: false)
          "NA to #{super}"
        end
      end
    end
  end
end