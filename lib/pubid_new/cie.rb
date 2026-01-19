# frozen_string_literal: true

require_relative "cie/identifier"
require_relative "cie/single_identifier"

module PubidNew
  module Cie
    # Main entry point for CIE identifiers
    # Delegates to Identifier.parse
    def self.parse(input)
      Identifier.parse(input)
    end
  end

  # Register CIE flavor in the global registry
end
