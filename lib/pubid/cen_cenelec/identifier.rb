# frozen_string_literal: true


module Pubid
  module CenCenelec
    # `extend Pubid::IdentifierFacade` adds polymorphic `from_hash` and pairs
    # with `include Pubid::CenCenelec::Identifier` in Identifiers::Base for
    # identity (`is_a?`/`===`), so a consumer handed this module can deserialize
    # and identity-check CEN/CENELEC ids through it.
    module Identifier
      extend Pubid::IdentifierFacade

      def self.parse(identifier)
        parsed = Parser.parse(identifier)
        Builder.new.build(parsed)
      rescue Parslet::ParseFailed => e
        raise "Failed to parse CEN identifier '#{identifier}': #{e.message}"
      end
    end
  end
end
