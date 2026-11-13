module Pubid
  module EtsiPfs
    class Identifier < ::Pubid::Identifier
      attribute :publisher, :string, default: -> { "ETSI" }

      PUBLISHER = "ETSI"

      # The scheme's declared publisher token: the internal-form
      # cut (to_s(with_publisher: false)) strips it from the
      # rendered face.
      def publisher_prefixes
        [PUBLISHER]
      end

      def self.parse(identifier)
        unless identifier.is_a?(String)
          raise Pubid::Errors::InvalidInputError,
                Pubid::INPUT_NOT_A_STRING_MESSAGE
        end

        if identifier.length > Pubid::MAX_INPUT_LENGTH
          raise Pubid::Errors::InvalidInputError, Pubid::INPUT_TOO_LONG_MESSAGE
        end

        identifier = ::Pubid.utf8_input(identifier)

        parsed = Pubid::Parg::Model.bound(:etsi_pfs, identifier)
        Builder.build(parsed)
      end
    end
  end
end
