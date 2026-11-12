  module Pubid
    module DoiPfs
      module Identifiers
        # Concrete DOI identifier type (PFS type `resource`).
        class Resource < Identifier
          TYPED_STAGES = [
            Pubid::Components::TypedStage.new(
              code: :pubdoi,
              stage_code: :published,
              type_code: :doi,
              abbr: ["DOI"],
              name: "DOI",
              harmonized_stages: [],
            ),
          ].freeze

          def self.type
            { key: :doi, web: :doi, title: "DOI", short: "DOI" }
          end

          # The scheme-canonical wire tag declared in the definition:
          # to_hash stays byte-identical with the scheme's coded
          # flavor, and this flavor's own from_hash routes the tag
          # to this class.
          def self.polymorphic_name
            "pubid:doi:resource"
          end
        end
      end
    end
  end
