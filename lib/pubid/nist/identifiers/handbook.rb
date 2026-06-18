# frozen_string_literal: true

module Pubid
  module Nist
    module Identifiers
      # NIST Handbook (HB)
      # Examples:
      # - "NIST HB 130" = Handbook 130
      # - "NBS HB 133" = NBS Handbook 133
      class Handbook < Base
        TYPED_STAGES = [
          Pubid::Components::TypedStage.new(
            abbr: ["HB", "NIST HB", "NBS HB"],
            stage_code: "published",
            type_code: "hb",
          ),
        ].freeze

        class << self
          def typed_stages
            TYPED_STAGES
          end

          def type
            { key: :hb,
            web: :handbook, title: "NIST Handbook", short: "HB" }
          end
        end

        def series_code
          "HB"
        end

        # Override to_s to handle edition+year pattern with dash instead of dot
        # Pattern: "44e2-1955" (dash separator) not "44e2.1955" (dot separator)
        def to_s(format = nil)
          # Use the base to_s method first
          result = super

          # If edition has additional_text (year), replace dot with dash
          if edition&.additional_text && !edition.additional_text.empty?
            result = result.gsub(/#{Regexp.escape(edition.type)}#{Regexp.escape(edition.id)}\.#{Regexp.escape(edition.additional_text)}/,
                                 "#{edition.type}#{edition.id}-#{edition.additional_text}")
          end

          result
        end
      end
    end
  end
end
