# frozen_string_literal: true

require_relative "base"

module PubidNew
  module Plateau
    module Identifiers
      # PLATEAU Technical Report
      # Format: PLATEAU Technical Report #NN[-annex]
      # Example: PLATEAU Technical Report #01
      class TechnicalReport < Base
        def type_string
          "Technical Report"
        end

        def to_s
          "#{publisher} #{type_string} #{formatted_number}#{formatted_annex}"
        end
      end
    end
  end
end
