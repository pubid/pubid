# frozen_string_literal: true

require_relative "base"

module PubidNew
  module Iso
    module Identifiers
      # ISO Guide
      # Format: ISO Guide NUMBER:YEAR
      class Guide < Base
        def to_s
          result = publisher.to_s
          result += " Guide #{code}"
          result += ":#{year}" if year
          result += "(#{language})" if language
          result
        end
      end
    end
  end
end