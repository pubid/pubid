# frozen_string_literal: true

require_relative "base"

module PubidNew
  module Cen
    module Identifiers
      # European Norm (EN) identifier
      class EuropeanNorm < Base
        def publisher
          ["EN"]
        end
      end
    end
  end
end