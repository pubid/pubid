require_relative "identifier"
# frozen_string_literal: true

module PubidNew
  module Ansi
    # Single ANSI identifier (non-bundled)
    class SingleIdentifier < Identifier
      def to_s(lang: :en)
        [].tap do |parts|
          parts << publisher_portion
          parts << number_portion
        end.compact.join(" ").tap do |s|
          s << language_portion if languages&.any?
        end
      end

      def publisher_portion
        if copublishers&.any?
          # ANSI/ISO 9899
          ([publisher] + copublishers).map(&:body).join("/")
        else
          # ANSI X3.4
          publisher.body
        end
      end

      def number_portion
        [
          number.value,
          (part ? "-#{part.value}" : ""),
          (date ? ":#{date.year}" : ""),
        ].join("")
      end

      def language_portion
        return "" unless languages&.any?

        "(#{languages.map(&:code).join(',')})"
      end
    end
  end
end
