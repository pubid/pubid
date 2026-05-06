# frozen_string_literal: true

module Pubid
  module Amca
    # Base class for single (non-supplement) ACMA identifiers
    # Includes: Standard, Publication
    class SingleIdentifier < Identifiers::Base

      def to_s
        parts = []
        parts << copublisher if copublisher
        # type is a hash, get the title
        t = begin
          self.type
        rescue NoMethodError
          nil
        end
        if t.is_a?(Hash) && t[:title]
          parts << t[:title].to_s
        end
        parts << code.to_s
        parts << "-#{year}" if year

        result = parts.compact.join(" ")

        # Handle additional copublisher after year (e.g., /ASHRAE 51-16)
        if copublisher&.include?("/") && year
          type_title = t.is_a?(Hash) ? t[:title].to_s : ""
          result = "#{copublisher} #{type_title} #{code}-#{year}"
        end

        result += " (#{reaffirmed})" if reaffirmed

        result
      end
    end
  end
end
