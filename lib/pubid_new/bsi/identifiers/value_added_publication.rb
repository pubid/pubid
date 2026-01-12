# frozen_string_literal: true

require_relative "base"

module PubidNew
  module Bsi
    module Identifiers
      # Value-Added Publication Identifier
      # Wraps base identifier with format suffix (PDF, TC, BOOK)
      # Similar to IEC VapIdentifier and BSI ExpertCommentary
      #
      # Examples:
      #   PD 5500:2018+A3:2020 PDF
      #   PAS 96:2017 - TC
      #   PP 7722:2006 BOOK
      class ValueAddedPublication < Base
        attribute :base_identifier, Base, polymorphic: true
        attribute :format, :string, values: ["PDF", "TC", "BOOK"]

        def to_s(lang: :en, lang_single: false)
          base_str = base_identifier.to_s(lang: lang, lang_single: lang_single)

          case format
          when "TC"
            "#{base_str} - TC"
          when "PDF"
            "#{base_str} PDF"
          when "BOOK"
            "#{base_str} BOOK"
          else
            base_str
          end
        end

        # Delegate common attributes to base_identifier
        def publisher
          base_identifier&.publisher
        end

        def number
          base_identifier&.number
        end

        def year
          base_identifier&.year
        end

        def date
          base_identifier&.date
        end
      end
    end
  end
end
