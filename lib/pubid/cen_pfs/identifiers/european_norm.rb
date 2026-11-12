  module Pubid
    module CenPfs
      module Identifiers
        # Concrete European Norm identifier type (PFS type `european_norm`).
        class EuropeanNorm < Identifier
          TYPED_STAGES = [
            Pubid::Components::TypedStage.new(
              code: :puben,
              stage_code: :published,
              type_code: :en,
              abbr: ["EN"],
              name: "European Norm",
              harmonized_stages: [],
            ),
          ].freeze

          def self.type
            { key: :en, web: :"european-norm", title: "European Norm", short: "EN" }
          end

          # The scheme-canonical wire tag declared in the definition:
          # to_hash stays byte-identical with the scheme's coded
          # flavor, and this flavor's own from_hash routes the tag
          # to this class.
          def self.polymorphic_name
            "pubid:cencenelec:european-norm"
          end
        end
      end
    end
  end
