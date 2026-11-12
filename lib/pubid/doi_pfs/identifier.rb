  module Pubid
    module DoiPfs
      class Identifier < ::Pubid::Identifier
        attribute :prefix, :string
        attribute :suffix, :string

        DOI_TYPE_MAP = {
          "pubid:doi:resource" => "Pubid::DoiPfs::Identifiers::Resource",
        }.freeze

        key_value do
          map "_type", to: :_type, polymorphic_map: DOI_TYPE_MAP
          map "prefix", to: :prefix
          map "suffix", to: :suffix
        end

        PUBLISHER = "DOI"

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

          parsed = Pubid::Parg::Model.bound(:doi_pfs, identifier)
          Builder.build(parsed)
        end
      end
    end
  end
