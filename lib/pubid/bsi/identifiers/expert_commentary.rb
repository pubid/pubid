# frozen_string_literal: true

module Pubid
  module Bsi
    module Identifiers
      # Expert Commentary Identifier
      # Wraps a base identifier with Expert Commentary suffix
      # Three formats:
      # 1. "Expert Commentary" (full form)
      # 2. "ExComm" (abbreviated form)
      # 3. "ExComm (Fire)" (with optional topic suffix)
      class ExpertCommentary < SingleIdentifier
        include RootIdentity

        attribute :base, ::Pubid::Identifier, polymorphic: true
        attribute :format, :string # "full", "abbr", "abbr_with_topic"
        attribute :topic, :string # e.g., "Fire"

        def publisher
          base&.publisher
        end

        # `number` and `year` are deliberately NOT delegated — a BSI wrapper
        # owns no identity, and a one-level delegation answered with nil
        # whenever `base` was itself a wrapper. `#root` carries identity for
        # every layer. See `Identifiers::RootIdentity` and docs/flavors/bsi.md.

        # Base document = the commented standard, fully peeled.
        def base_document
          base&.base_document || self
        end
      end
    end
  end
end
