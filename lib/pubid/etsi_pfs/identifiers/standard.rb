  module Pubid
    module EtsiPfs
      module Identifiers
        # Concrete ETSI Standard identifier type (PFS type `standard`).
        class Standard < Identifier
          TYPED_STAGES = [].freeze

          def self.type
            { key: :etsi, web: :etsi, title: "ETSI Standard", short: "ETSI" }
          end

          # The scheme-canonical wire tag declared in the definition:
          # to_hash stays byte-identical with the scheme's coded
          # flavor, and this flavor's own from_hash routes the tag
          # to this class.
          def self.polymorphic_name
            "pubid:etsi:etsi-standard"
          end
        end
      end
    end
  end
