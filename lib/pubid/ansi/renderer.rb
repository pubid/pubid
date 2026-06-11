# frozen_string_literal: true

module Pubid
  module Ansi
    # Human-readable renderer for ANSI identifiers.
    #
    # Produces strings like:
    #   "ANSI X3.4"
    #   "ANSI/ISO 9899"
    #   "ANSI X9.8-1:2007"
    #
    # The renderer is registered as the `:human` format in the ANSI format
    # registry and invoked via `render(format: :human)`.
    class Renderer < ::Pubid::Renderers::Base
      def render(context: nil, **opts)
        id = @id

        parts = []
        parts << publisher_portion(id)
        parts << number_portion(id)
        result = parts.compact.join(" ")

        result << language_portion(id) if id.languages&.any?

        result
      end

      private

      def publisher_portion(id)
        if id.copublishers&.any?
          ([id.publisher] + id.copublishers).map(&:body).join("/")
        else
          id.publisher.body
        end
      end

      def number_portion(id)
        [
          id.number.value,
          (id.part ? "-#{id.part.value}" : ""),
          (id.date ? ":#{id.date.year}" : ""),
        ].join
      end

      def language_portion(id)
        return "" unless id.languages&.any?

        "(#{id.languages.map(&:code).join(',')})"
      end
    end
  end
end
