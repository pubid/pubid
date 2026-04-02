# frozen_string_literal: true

require_relative "base"

module PubidNew
  module Ieee
    module Identifiers
      # Redlined Standard Identifier
      # IEEE standard with optional revision note, marked as redline
      # Example: "IEEE Std 1018-2013 (Revison of IEEE Std 1018-2004) - Redline"
      # Contains: base standard + optional revision standard + redline flag
      class RedlinedStandard < Base
        # The current standard identifier
        attribute :base_identifier, Base, polymorphic: true

        # Optional: the standard this revises
        attribute :revision_of, Base, polymorphic: true

        # Redline flag (always true for this class)
        attribute :redline, :boolean, default: -> { true }

        def to_s
          result = base_identifier.to_s
          result += " (Revision of #{revision_of})" if revision_of
          result += " - Redline" if redline
          result
        end

        def publisher
          base_identifier&.publisher || "IEEE"
        end
      end
    end
  end
end
