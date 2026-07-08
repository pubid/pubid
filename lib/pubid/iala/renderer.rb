# frozen_string_literal: true

module Pubid
  module Iala
    # Human-readable renderer for IALA identifiers.
    #
    # Produces strings like:
    #   "IALA S1070"
    #   "IALA S1070 Ed 2.0"
    #   "IALA R1016 Ed 2.0 (F)"
    class Renderer < ::Pubid::Renderers::Base
      def render(context: nil, **_opts)
        id = @id

        return render_annex(id) if id.is_a?(Identifiers::Annex)

        rendered = "#{id.publisher} #{id.type_letter}#{id.number}"
        rendered << " Ed #{id.edition}" if id.edition
        rendered << " (#{id.language})" if id.language
        rendered
      end

      # Render an Annex wrapper. The base identifier is rendered first, then
      # the marker form is preserved verbatim ("Annex" vs "ANNEX"), then the
      # optional letter, edition, and language.
      def render_annex(id)
        base_str = id.base_identifier.to_s
        rendered = "#{base_str} #{id.annex_form}"
        rendered << " #{id.letter}" if id.letter
        rendered << " Ed #{id.edition}" if id.edition
        rendered << " (#{id.language})" if id.language
        rendered
      end
    end
  end
end
