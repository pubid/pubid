# frozen_string_literal: true

require_relative "../single_identifier"

module PubidNew
  module Jis
    module Identifiers
      # Technical Specification identifier type
      # Format: JIS TS SERIES NUMBER:YEAR
      # Example: JIS TS Z 0030-1:2017
      class TechnicalSpecification < SingleIdentifier
        def type_prefix
          "TS"
        end
      end
    end
  end
end