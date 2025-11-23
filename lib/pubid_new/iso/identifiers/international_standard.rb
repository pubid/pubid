# frozen_string_literal: true

require_relative "base"

module PubidNew
  module Iso
    module Identifiers
      # ISO International Standard
      # Format: ISO NUMBER[-PART]:YEAR
      # Format: ISO/IEC NUMBER[-PART]:YEAR
      class InternationalStandard < Base
        # Default type is IS (no type prefix in output)
      end
    end
  end
end
