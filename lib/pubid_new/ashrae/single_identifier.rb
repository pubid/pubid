# frozen_string_literal: true

require "lutaml/model"
require_relative "identifiers/base"

module PubidNew
  module Ashrae
    # Base class for single (non-supplement) ASHRAE identifiers
    # Includes: Guideline, Standard
    class SingleIdentifier < Identifiers::Base
      def to_s
        parts = []
        parts << publisher if publisher
        parts << type.to_s if type
        result = parts.join(" ")
        result += " " if result.length > 0
        result += code.to_s
        result += "-#{year}" if year
        result += " (#{amendment})" if amendment
        result += suffix if suffix
        result += " (RA#{reaffirmed})" if reaffirmed
        result
      end
    end
  end
end
