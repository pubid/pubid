# frozen_string_literal: true

module Pubid
  module Jcgm
    # Human-readable renderer for JCGM identifiers.
    #
    # Produces strings like:
    #   "JCGM 100:2008"
    #   "JCGM 100:2008/Amd 1:2023"
    #   "JCGM GUM-6:2020"
    #
    # The renderer is registered as the `:human` format in the JCGM format
    # registry and invoked via `render(format: :human)`.
    class Renderer < ::Pubid::Renderers::Base
      def render(context: nil, **opts)
        id = @id

        case id
        when Identifiers::Amendment
          render_amendment(id)
        when Identifiers::GumGuide
          render_gum_guide(id)
        else
          render_single(id)
        end
      end

      private

      def render_single(id)
        parts = [id.publisher_portion]
        parts << id.number_portion unless id.number_portion.empty?
        result = parts.join(" ")
        result += id.language_portion if id.languages&.any?
        result
      end

      def render_amendment(id)
        result = id.base_identifier.to_s if id.base_identifier
        result += "/Amd"
        result += " #{id.iteration.value}" if id.iteration
        result += ":#{id.date}" if id.date
        result
      end

      def render_gum_guide(id)
        parts = []
        parts << id.publisher.publisher if id.publisher
        parts << "GUM-#{id.gum_number.value}" if id.gum_number

        result = parts.join(" ")
        result += ":#{id.date}" if id.date
        result += gum_language_portion(id) if id.languages&.any?
        result
      end

      def gum_language_portion(id)
        return "" unless id.languages&.any?

        codes = id.languages.map do |lang|
          lang.original_code || lang.code
        end

        "(#{codes.join('/')})"
      end
    end
  end
end
