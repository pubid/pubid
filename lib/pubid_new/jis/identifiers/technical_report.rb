# frozen_string_literal: true

require_relative "../single_identifier"

module PubidNew
  module Jis
    module Identifiers
      # Technical Report identifier type
      # Format: JIS TR SERIES NUMBER:YEAR
      # Example: JIS TR Z 8301:2019
      class TechnicalReport < SingleIdentifier
        def type_prefix
          "TR"
        end
      end
    end
  end
end
