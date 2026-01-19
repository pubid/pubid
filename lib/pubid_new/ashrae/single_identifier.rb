# frozen_string_literal: true

require_relative "../serializable"


require_relative "urn_generator"
require_relative "identifiers/base"

module PubidNew
  module Ashrae
    # Base class for single (non-supplement) ASHRAE identifiers
    # Includes: Guideline, Standard
    class SingleIdentifier < Identifiers::Base
      include PubidNew::Serializable

      def to_s
        parts = []
        parts << publisher if publisher
        parts << type.to_s if type
        result = parts.join(" ")
        result += " " if result.length.positive?
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
