# frozen_string_literal: true

require "lutaml/model"
require_relative "identifiers/base"

module PubidNew
  module Amca
    # Base class for single (non-supplement) ACMA identifiers
    # Includes: Standard, Publication
    class SingleIdentifier < Identifiers::Base
      def to_s
        parts = []
        parts << copublisher if copublisher
        parts << type.to_s.capitalize if respond_to?(:type)
        parts << code.to_s
        parts << "-#{year}" if year

        result = parts.compact.join(" ")

        # Handle additional copublisher after year (e.g., /ASHRAE 51-16)
        if copublisher && copublisher.include?("/") && year
          result = "#{copublisher} #{respond_to?(:type) ? type.to_s.capitalize : ''} #{code}-#{year}"
        end

        result += " (#{reaffirmed})" if reaffirmed

        result
      end
    end
  end
end
