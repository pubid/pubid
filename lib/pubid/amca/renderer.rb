# frozen_string_literal: true

module Pubid
  module Amca
    # Human-readable renderer for AMCA identifiers.
    #
    # Produces strings like:
    #   "AMCA Standard 210-16"
    #   "AMCA Publication 211-22 (Rev. 01-23)"
    #   "ANSI/AMCA 204 Interp"
    #   "AMCA 99 JW Interp"
    #
    # The renderer is registered as the `:human` format in the AMCA format
    # registry and invoked via `render(format: :human)`.
    class Renderer < ::Pubid::Renderers::Base
      def render(context: nil, **opts)
        id = @id

        case id
        when Identifiers::Publication
          render_publication(id)
        when Identifiers::Interpretation
          render_interpretation(id)
        else
          render_base(id)
        end
      end

      private

      def render_base(id)
        t = id.class.respond_to?(:type) ? id.class.type : nil
        title = t[:title].to_s if t.is_a?(Hash) && t[:title]
        result = document(id, title)
        result += " (R#{id.reaffirmed})" if id.reaffirmed
        result
      end

      # The revision and the reaffirmation are separate optional groups in
      # the grammar, so either or both can appear.
      def render_publication(id)
        result = document(id, "Publication")
        result += " (Rev. #{id.revision})" if id.revision
        result += " (R#{id.reaffirmed})" if id.reaffirmed
        result
      end

      def render_interpretation(id)
        result = [id.copublisher, id.number.to_s].compact.join(" ")

        if id.interpretation_code
          result += " #{id.interpretation_code} Interp"
        elsif id.year
          result += " – #{id.year}"
        else
          result += " Interp"
        end

        result += " #{id.suffix}" if id.suffix
        result
      end

      # "AMCA Standard 803-02": the year joins the number with a bare dash.
      def document(id, title)
        result = [id.copublisher, title, id.number.to_s].compact.join(" ")
        result += "-#{id.year}" if id.year
        result
      end
    end
  end
end
