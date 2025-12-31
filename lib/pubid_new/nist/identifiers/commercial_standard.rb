# frozen_string_literal: true

require_relative "base"

module PubidNew
  module Nist
    module Identifiers
      # NBS/NIST CS (Commercial Standard)
      # Distinct from CS-E (emergency) and CSM (monthly)
      # Examples:
      # - "NBS CS 102" - Basic commercial standard
      # - "NBS CS 102E-42" - With letter suffix and number
      # - "CS 190-58" - With year
      class CommercialStandard < Base
        def default_publisher
          "NBS"
        end

        def series_code
          "CS"
        end
      end
    end
  end
end