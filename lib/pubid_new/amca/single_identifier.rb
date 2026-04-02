# frozen_string_literal: true

require_relative "../serializable"


require_relative "urn_generator"
require_relative "identifiers/base"

module PubidNew
  module Amca
    # Base class for single (non-supplement) ACMA identifiers
    # Includes: Standard, Publication
    class SingleIdentifier < Identifiers::Base
      include PubidNew::Serializable

      def to_s
        parts = []
        parts << copublisher if copublisher
        # type is a hash, get the title
        if respond_to?(:type) && type.is_a?(Hash)
          parts << type[:title].to_s if type[:title]
        end
        parts << code.to_s
        parts << "-#{year}" if year

        result = parts.compact.join(" ")

        # Handle additional copublisher after year (e.g., /ASHRAE 51-16)
        if copublisher && copublisher.include?("/") && year
          type_title = respond_to?(:type) && type.is_a?(Hash) ? type[:title].to_s : ''
          result = "#{copublisher} #{type_title} #{code}-#{year}"
        end

        result += " (#{reaffirmed})" if reaffirmed

        result
      end
    end
  end
end
