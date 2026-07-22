# frozen_string_literal: true

module Pubid
  module Nist
    module Identifiers
      # NIST Technical Note (TN)
      # Examples:
      # - "NIST TN 1234" = Technical Note 1234
      # - "NBS TN 567" = NBS Technical Note 567
      class TechnicalNote < Identifier
        TYPED_STAGES = [
          Pubid::Components::TypedStage.new(
            abbr: ["TN", "NIST TN", "NBS TN"],
            stage_code: "published",
            type_code: "tn",
          ),
        ].freeze

        class << self
          def typed_stages
            TYPED_STAGES
          end

          def type
            { key: :tn,
            web: :technical_note, title: "NIST Technical Note", short: "TN" }
          end
        end

        def series_code
          "TN"
        end

        # Override update_component setter to add default year for TN dash-prefix updates
        def update_component=(value)
          super

          # TN-SPECIFIC: Add default year to "-upd" pattern (no year/month)
          # Pattern: "NIST TN 2150-upd" → update gets default year=2021, month=02
          if value && value.prefix == "dash" && !value.year
            # Create new Update with default year 2021 and month 02
            default_update = Components::Update.new(
              number: value.number || "1",
              year: "2021",
              month: "02",
              prefix: "slash",
            )
            # Set both update and update_component to the new object
            super(default_update)
            self.update = default_update
          end
        end

        def to_s(format = nil)
          # TN-SPECIFIC: Add default year to "-upd" pattern (no year/month)
          # Pattern: "NIST TN 2150-upd" → "NIST TN 2150/Upd1-202102"
          # This is a special TN pattern where -upd gets default number=1 and year=202102
          if update_component && !update_component.year && update_component.prefix == "dash"
            # Create new Update with default year 202102 (February 2021)
            # This ensures both rendering and attribute access work correctly
            self.update = Components::Update.new(number: update_component.number || "1",
                                                 year: "2021", month: "02", prefix: "slash")
            self.update_component = update
          end

          # Call parent implementation
          super
        end

        public

        def to_short_style
          # Call parent implementation
          result = super

          # TN-SPECIFIC: For edition years (not with edition number), use 'e' prefix instead of dash
          # Pattern: "NIST TN 1297-1993" → "NIST TN 1297e1993"
          # But only if edition_year is set and edition is NOT set
          if !edition && edition_year
            # Replace the last occurrence of "-YYYY" with "eYYYY"
            # This handles both "-1993" and "-Feb1985" formats
            result = result.sub(/-(\d{4})$/, 'e\1')
            result = result.sub(/-([A-Za-z]{3,9})(\d{4})$/, 'e\1\2')
          end

          result
        end
      end
    end
  end
end
