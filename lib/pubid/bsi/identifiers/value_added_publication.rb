# frozen_string_literal: true

module Pubid
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
      class ValueAddedPublication < SingleIdentifier
        attribute :base, ::Pubid::Identifier, polymorphic: true
        attribute :format, :string, values: ["PDF", "TC", "BOOK"]

        # Delegate common attributes to base
        def publisher
          base&.publisher
        end

        def number
          base&.number
        end

        def year
          base&.year
        end

        def date
          base&.date
        end
      end
    end
  end
end
