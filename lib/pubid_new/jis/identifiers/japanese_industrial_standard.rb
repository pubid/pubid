# frozen_string_literal: true

require_relative "../single_identifier"

module PubidNew
  module Jis
    module Identifiers
      # Default JIS identifier type (no type prefix)
      # Examples: JIS A 0001:1999, JIS B 0060-1:2015
      class JapaneseIndustrialStandard < SingleIdentifier
        # No type prefix for default standards
        def type_prefix
          nil
        end
      end
    end
  end
end