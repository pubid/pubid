# frozen_string_literal: true

module Pubid
  module Bsi
    module Identifiers
      # DISC (Delivering Information Solutions to Customers) identifier
      # Examples: "DISC PD 2000-2:1997", "DISC PD 3004:1998"
      class Disc < SingleIdentifier
        TYPED_STAGES = [
          Pubid::Components::TypedStage.new(
            code: :disc,
            stage_code: :published,
            type_code: :disc,
            abbr: ["DISC"],
            name: "DISC",
            harmonized_stages: %w[60.00 60.60],
          ),
        ].freeze

        def self.type
          { key: :disc, title: "DISC", short: "DISC" }
        end

        def to_s(lang: :en, lang_single: false)
          render(format: :human, lang: lang, lang_single: lang_single)
        end
      end
    end
  end
end
