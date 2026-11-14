module Pubid
  module CenPfs
    module Identifiers
      # Concrete European Norm identifier type (PFS type `european_norm`).
      class EuropeanNorm < Identifier
          TYPED_STAGES = [
          ::Pubid::Components::TypedStage.new(
            code: :puben, stage_code: :published,
            type_code: :en, abbr: ["EN"],
            name: "European Norm", harmonized_stages: [],
          ),
          ::Pubid::Components::TypedStage.new(
            code: :pren, stage_code: :proposal,
            type_code: :en, abbr: ["prEN"],
            name: "pren", harmonized_stages: [],
          ),
          ::Pubid::Components::TypedStage.new(
            code: :fpren, stage_code: :final_proposal,
            type_code: :en, abbr: ["FprEN"],
            name: "fpren", harmonized_stages: [],
          ),
          ].freeze

        def self.type
          { key: :en, web: :"european-norm", title: "European Norm", short: "EN" }
        end

        # The publisher default (feature 5): the type's own token
        # when the type is its designation, else the scheme default.
        def self.default_publisher
          ::Pubid::Components::Publisher.new(body: "EN")
        end

        attribute :publisher, ::Pubid::Components::Publisher, default: -> { self.class.default_publisher }
        attribute :type, ::Pubid::Components::Type, default: -> { self.class.default_type }

        def self.default_type
          ::Pubid::Components::Type.new(abbr: type[:short])
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
