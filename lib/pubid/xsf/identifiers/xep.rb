# frozen_string_literal: true

module Pubid
  module Xsf
    module Identifiers
      # XMPP Extension Protocol — the sole XSF identifier type.
      # Format: "XEP NNNN" (e.g. XEP 0001, XEP 0218).
      #
      # `polymorphic_name` auto-derives "pubid:xsf:xep" from the class name,
      # which is what serializes into the `_type` tag and drives from_hash
      # dispatch (see XSF_TYPE_MAP on the base Identifier).
      class Xep < Identifier
        TYPED_STAGES = [
          Pubid::Components::TypedStage.new(
            code: :xep,
            stage_code: :published,
            type_code: :xep,
            abbr: ["XEP"],
            name: "XMPP Extension Protocol",
            harmonized_stages: [],
          ),
        ].freeze

        def self.type
          { key: :xep,
            web: :xep, title: "XMPP Extension Protocol", short: "XEP" }
        end
      end
    end
  end
end
