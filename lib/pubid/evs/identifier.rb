# frozen_string_literal: true

module Pubid
  module Evs
    # An EVS national adoption wraps a CEN identifier the same way BSI's
    # AdoptedEuropeanNorm does — polymorphic `base` so the
    # wrapped object stays a real Pubid::CenCenelec identifier.
    #
    # Examples:
    #   "EVS-EN 18216:2026"           (base: EN 18216:2026)
    #   "EVS-EN ISO 14001:2026"       (base: EN ISO 14001:2026)
    #   "EVS-EN ISO/IEC 27017:2026"   (base: EN ISO/IEC 27017:2026)
    #   "EVS-EN ISO 9001:2015/A1:2024" (base: EN ISO 9001:2015/A1:2024)
    class Identifier < ::Pubid::Identifier
      attribute :base, ::Pubid::Identifier, polymorphic: true
      # "-" or " " — preserves the printed separator ("EVS-EN" vs "EVS EN")
      attribute :separator, :string, default: -> { "-" }

      def to_s(**opts)
        render(format: :human, **opts)
      end

      def self.parse(string)
        unless string.is_a?(String)
          raise Pubid::Errors::InvalidInputError,
                Pubid::INPUT_NOT_A_STRING_MESSAGE
        end

        if string.length > Pubid::MAX_INPUT_LENGTH
          raise Pubid::Errors::InvalidInputError, Pubid::INPUT_TOO_LONG_MESSAGE
        end

        Pubid::Evs.parse(string)
      end
    end
  end
end
