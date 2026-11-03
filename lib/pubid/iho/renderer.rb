# frozen_string_literal: true

module Pubid
  module Iho
    # Human-readable renderer for IHO identifiers.
    #
    # Canonical faces (owner rulings, 2026-11-03):
    #   "IHO S-100"                     undated (edition-non-specific)
    #   "IHO S-100 1.0.0"               dated (edition-specific)
    #   "IHO S-100 5.0.0 Part 2"        edition BEFORE the part
    #   "IHO S-98 1.0.0 Part A Annex B"
    #   "IHO S-122 1.0.0 Appendix D-2"  canonical Appendix, subnumber
    #                                   joined by a dash
    #   "IHO M-2 Sup 1"                 canonical Sup (Suppl is an input
    #                                   alias)
    #   "IHO P-1 Vol. 30 (2)"           volume-keyed series (P-1, P-6)
    #   "IHO P-5 Vol. 2024"             the yearbook year IS a volume
    #   "IHO S-100 5.0.0 Part 2 (2024)" the with-year qualifier: a year
    #                                   beside an edition is the date
    #                                   qualifier on standards,
    #                                   parenthesized — the only year face
    #
    # The renderer is registered as the `:human` format in the IHO format
    # registry and invoked via `render(format: :human)`; the compact face
    # (`IHO S-100-1 5.0.0`, `IHO M-2-2`, `IHO P-5/2024`) is the opt-in
    # `compact: true` flag, and `with_publisher: false` drops the leading
    # publisher as everywhere else. The legacy faces (glued lettered
    # bases, Suppl, bare years) parse but are never rendered.
    class Renderer < ::Pubid::Renderers::Base
      # The canonical component faces in print order: edition BEFORE the
      # part; each independently-publishable component carries its own
      # edition (+ parenthesized year) right after it; the appendix joins
      # its subnumber; the issue rides parenthesized after its volume;
      # the base year prints only as the parenthesized with-year
      # qualifier.
      FACES = [
        [:edition, " %s"],
        [:supplement, " Sup %s"], [:supplement_edition, " %s"],
        [:supplement_year, " (%s)"],
        [:part, " Part %s"], [:part_edition, " %s"], [:part_year, " (%s)"],
        [:annex, " Annex %s"], [:annex_edition, " %s"], [:annex_year, " (%s)"],
        [:appendix, " Appendix %s"], [:appendix_subnumber, "-%s"],
        [:appendix_edition, " %s"], [:appendix_year, " (%s)"],
        [:volume, " Vol. %s"], [:issue, " (%s)"],
        [:volume_edition, " %s"], [:volume_year, " (%s)"],
        [:year, " (%s)"]
      ].freeze

      def render(context: nil, **opts)
        id = @id
        rendered = "#{id.publisher} #{id.class.type[:short]}-#{id.number}"
        FACES.each do |component, face|
          value = id.public_send(component)
          rendered << (face % value) if value
        end
        rendered
      end
    end
  end
end
