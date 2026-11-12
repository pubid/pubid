  module Pubid
    module CalconnectPfs
      module Identifiers
        # Concrete CalConnect Standard identifier type (PFS type `standard`).
        class Standard < Identifier
          TYPED_STAGES = [
            Pubid::Components::TypedStage.new(
              code: :pubcc,
              stage_code: :published,
              type_code: :cc,
              abbr: ["CC"],
              name: "CalConnect Standard",
              harmonized_stages: [],
            ),
          ].freeze

          def self.type
            { key: :cc, web: :standard, title: "CalConnect Standard", short: "CC" }
          end

          # The scheme-canonical wire tag declared in the definition:
          # to_hash stays byte-identical with the scheme's coded
          # flavor, and this flavor's own from_hash routes the tag
          # to this class.
          def self.polymorphic_name
            "pubid:calconnect:standard"
          end
        end
      end
    end
  end
