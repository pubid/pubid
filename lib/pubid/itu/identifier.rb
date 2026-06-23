# frozen_string_literal: true

module Pubid
  module Itu
    # NOTE: intentionally does NOT `extend Pubid::IdentifierFacade`. ITU's
    # `to_hash` currently raises (publisher stored as a String, not a Publisher
    # component), so enabling the facade's identity check would route ITU ids
    # through a consumer's `to_hash` (e.g. relaton-index#save) and crash.
    # Re-enable once ITU serialization round-trips cleanly. See
    # identifier_facade.rb.
    module Identifier
      def self.parse(identifier)
        parsed = Parser.parse(identifier)
        Builder.build(parsed)
      rescue Parslet::ParseFailed => e
        raise "Failed to parse ITU identifier '#{identifier}': #{e.message}"
      end
    end
  end
end
