  module Pubid
    module EtsiPfs
      class Identifier < ::Pubid::Identifier
        attribute :type, :string
        attribute :number, :string
        attribute :minor, :string
        attribute :parts, :string
        attribute :supplements, :string
        attribute :version, :string
        attribute :edition, :string
        attribute :year, :string
        attribute :month, :string

        ETSI_TYPE_MAP = {
          "pubid:etsi:etsi-standard" => "Pubid::EtsiPfs::Identifiers::Standard",
        }.freeze

        key_value do
          map "_type", to: :_type, polymorphic_map: ETSI_TYPE_MAP
          map "type", to: :type
          map "number", to: :number
          map "minor", to: :minor
          map "parts", to: :parts
          map "supplements", to: :supplements
          map "version", to: :version
          map "edition", to: :edition
          map "year", to: :year
          map "month", to: :month
        end

        PUBLISHER = "ETSI"

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
