# frozen_string_literal: true

module Pubid
  module Nist
    # NIST factory entry point. `.parse` lives on `Pubid::Nist` itself for
    # historical reasons; this module hosts the rest of the flavor-facade API
    # (`from_hash`, identity) for consistency with the other pubid flavors.
    #
    # `extend Pubid::IdentifierFacade` adds polymorphic `from_hash` dispatch
    # over the NIST `_type` registry; the matching `include Pubid::Nist::
    # Identifier` in Identifiers::Base makes every concrete NIST identifier
    # `is_a?(Pubid::Nist::Identifier)` (and `=== id`), so a consumer handed this
    # module (e.g. relaton-index's `pubid_class`) can both deserialize and
    # identity-check NIST ids through it.
    module Identifier
      extend Pubid::IdentifierFacade

      # Delegate to the flavor module so callers can use
      # `Pubid::Nist::Identifier.parse` consistently with other flavors.
      def self.parse(identifier)
        Pubid::Nist.parse(identifier)
      end
    end
  end
end
