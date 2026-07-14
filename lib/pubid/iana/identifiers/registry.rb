# frozen_string_literal: true

module Pubid
  module Iana
    module Identifiers
      # The sole IANA identifier type: a protocol registry (optionally with a
      # sub-registry). Its class name yields the polymorphic `_type` tag
      # "pubid:iana:registry".
      #
      # Examples:
      #   IANA _6lowpan-parameters
      #   IANA _6lowpan-parameters/lowpan_nhc
      class Registry < Identifier
        # IANA registries carry no revision/stage lifecycle; a single published
        # typed stage keeps parity with the other flavors' type registries.
        TYPED_STAGES = [
          Pubid::Components::TypedStage.new(
            code: :pubiana,
            stage_code: :published,
            type_code: :iana,
            abbr: ["IANA"],
            name: "IANA Registry",
            harmonized_stages: [],
          ),
        ].freeze

        def self.type
          { key: :iana, web: :registry, title: "IANA Registry", short: "IANA" }
        end
      end
    end
  end
end
