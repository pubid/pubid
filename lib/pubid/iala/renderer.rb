# frozen_string_literal: true

module Pubid
  module Iala
    # Human-readable renderer for IALA identifiers.
    #
    # Produces strings like:
    #   "IALA S1070"
    #   "IALA S1070 Ed 2.0"
    #   "IALA R1016 Ed 2.0 (F)"
    #   "IALA arctic-seminar-report (E)"
    #   "S-201 2.0.0"   (the S-100-family bare designation face)
    class Renderer < ::Pubid::Renderers::Base
      def render(context: nil, **_opts)
        id = @id

        return render_annex(id) if id.is_a?(Identifiers::Annex)
        return render_product_spec(id) if id.is_a?(Identifiers::ProductSpecification)

        # A codeless Publication has no type letter: "IALA <slug>".
        rendered = "#{id.publisher} #{id.type_letter}#{id.number}"
        rendered << " Ed #{id.edition}" if id.edition
        rendered << " (#{id.language})" if id.language
        rendered
      end

      # The S-100-family face: the hyphenated designation and the bare
      # dotted edition, no publisher token — the S-100 lexical law IALA's
      # own S-201 citation form follows ("S-201 2.0.0"), the same
      # designation-not-publisher rule as the WMO-published S-100 specs.
      def render_product_spec(id)
        rendered = "S-#{id.number}"
        rendered << " #{id.edition}" if id.edition
        rendered << " (#{id.language})" if id.language
        rendered
      end

      # Render an Annex wrapper. The base identifier is rendered first, then
      # the marker form is preserved verbatim ("Annex" vs "ANNEX"), then the
      # optional letter, edition, and language. The edition face follows the
      # base's family: bare for an S-100-family base, "Ed" for the legacy
      # series.
      def render_annex(id)
        base_str = id.base.to_s
        s100_base = id.base.is_a?(Identifiers::ProductSpecification)
        rendered = "#{base_str} #{id.annex_form}"
        rendered << " #{id.letter}" if id.letter
        if id.edition
          rendered << (s100_base ? " #{id.edition}" : " Ed #{id.edition}")
        end
        rendered << " (#{id.language})" if id.language
        rendered
      end
    end
  end
end
