# frozen_string_literal: true

require_relative "base"

module PubidNew
  module Nist
    module Identifiers
      # NIST Grant/Contractor Report (GCR)
      # Examples:
      # - "NIST GCR 17-917-45" - Basic 3-part number
      # - "NIST GCR 21-917-48v3B" - With volume and letter suffix
      class GrantContractorReport < Base
        def series_code
          "GCR"
        end
      end
    end
  end
end
