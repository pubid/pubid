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
        attribute :base_identifier, ::Pubid::Identifier, polymorphic: true
        attribute :format, :string # "full", "abbr", "abbr_with_topic"
        attribute :topic, :string # e.g., "Fire"

        def publisher
          base_identifier&.publisher
        end

        def number
          base_identifier&.number
        end

        def year
          base_identifier&.year
        end

        # Base document = the commented standard, fully peeled.
        def base_document
          base_identifier&.base_document || self
        end
      end
    end
  end
end
