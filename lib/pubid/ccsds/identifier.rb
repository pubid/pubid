# frozen_string_literal: true

module Pubid
  module Ccsds
    module Identifier
      def self.parse(identifier)
        # Apply legacy update_codes normalization first
        normalized = Core::UpdateCodes.apply(identifier, :ccsds)
        parsed = Pubid::Ccsds::Parser.parse(normalized)
        Pubid::Ccsds::Builder.build(parsed)
      rescue Parslet::ParseFailed => e
        raise "Failed to parse CCSDS identifier '#{identifier}': #{e.message}"
      end
    end
  end
end
