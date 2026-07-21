# frozen_string_literal: true

module Pubid
  module Ieee
    module Identifiers
      # Redlined Standard Identifier
      # IEEE standard with optional revision note, marked as redline
      # Example: "IEEE Std 1018-2013 (Revison of IEEE Std 1018-2004) - Redline"
      # Contains: base standard + optional revision standard + redline flag
      class RedlinedStandard < Base
        # The current standard identifier
        attribute :base, Base, polymorphic: true

        # Optional: the standard this revises
        attribute :revision_of, Base, polymorphic: true

        # Redline flag (always true for this class)
        attribute :redline, :boolean, default: -> { true }

        def publisher
          base&.publisher || "IEEE"
        end
      end
    end
  end
end
