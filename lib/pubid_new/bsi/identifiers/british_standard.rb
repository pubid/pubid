# frozen_string_literal: true

require_relative "base"

module PubidNew
  module Bsi
    module Identifiers
      # British Standard (BS) identifier
      class BritishStandard < Base
        def publisher
          "BS"
        end
      end
    end
  end
end