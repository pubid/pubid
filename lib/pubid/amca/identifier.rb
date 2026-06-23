# frozen_string_literal: true

module Pubid
  module Amca
    # NOTE: this flavor intentionally does NOT `extend Pubid::IdentifierFacade`
    # (nor include it in Identifiers::Base). The facade's identity check makes
    # `is_a?(<Flavor>::Identifier)` true, which routes the object through a
    # consumer's `to_hash` (e.g. relaton-index#save) — but AMCA's `to_hash`
    # currently raises (publisher is stored as a String, not a Publisher
    # component). Enabling the facade here would turn a non-crashing path into a
    # crash. Re-enable once AMCA serialization round-trips cleanly.
    module Identifier
      # Parse an ACMA identifier string into an identifier object
      # @param identifier [String] The ACMA identifier string to parse
      # @return [Pubid::Amca::Identifier] The appropriate identifier object
      # @raise [Parslet::ParseFailed] If parsing fails
      def self.parse(identifier)
        parsed = Parser.parse(identifier)
        Builder.build(parsed)
      rescue Parslet::ParseFailed => e
        raise "Failed to parse ACMA identifier '#{identifier}': #{e.message}"
      end
    end
  end
end
