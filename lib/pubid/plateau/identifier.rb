# frozen_string_literal: true

module Pubid
  module Plateau
    # Plateau factory entry point. `.parse` lives on `Pubid::Plateau`
    # itself for historical reasons; this module hosts `.create` for API
    # consistency with the other pubid flavors.
    #
    # NOTE: intentionally does NOT `extend Pubid::IdentifierFacade`. PLATEAU's
    # `to_hash` currently raises (publisher stored as a String, not a Publisher
    # component), so enabling the facade's identity check would route PLATEAU
    # ids through a consumer's `to_hash` (e.g. relaton-index#save) and crash.
    # Re-enable once PLATEAU serialization round-trips cleanly. See
    # identifier_facade.rb.
    module Identifier
      # Delegate to the flavor module so callers can use
      # `Pubid::Plateau::Identifier.parse` consistently with other flavors.
      def self.parse(identifier)
        Pubid::Plateau.parse(identifier)
      end
    end
  end
end
