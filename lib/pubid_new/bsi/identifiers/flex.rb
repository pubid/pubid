# frozen_string_literal: true

require_relative "base"

module PubidNew
  module Bsi
    module Identifiers
      # BSI Flex document identifier
      class Flex < Base
        def publisher
          "BSI Flex"
        end
      end
    end
  end
end
