# frozen_string_literal: true

module Pubid
  module Iho
    # Generates URN strings for IHO identifiers.
    #
    # The URN is the documented positional segment grammar (see the
    # grammar header in pubid-grammar's grammars/iho.parg and the flavor
    # notes): containment-ordered, one semantic atom per segment, every
    # non-number component a marker-prefixed segment whose marker is the
    # lowercased human-face token (edition follows ISO's ed- precedent):
    #
    #   urn:iho:<type>:<number>[:ed-<x.y.z>][:sup-<n>][:part-<X>]
    #     [:annex-<A>][:appendix-<B>][:<sub>][:vol-<n>][:issue-<n>]
    #     [:year-<yyyy>]
    #
    # Containment: part contains annexes, annex contains appendices, the
    # subnumber is a child atom of its appendix, the issue a child of its
    # volume. Letters are case-preserved. The volume carries every serial
    # locator — the yearbook year IS a volume (P-5 Vol. 2024 gives
    # vol-2024), so a periodical identifier has no year segment; the
    # year- segment exists only for the standards with-year qualifier.
    # Both are marker-tagged so neither can collide with a colon-number
    # segment (the number is not escaped and may span bare segments:
    # "IHO S-158:100" gives "urn:iho:s:158:100").
    #
    # Examples:
    # - urn:iho:s:44:ed-5.0.0                     IHO S-44 5.0.0
    # - urn:iho:s:100:ed-5.0.0:part-2:year-2024   IHO S-100 5.0.0 Part 2 (2024)
    # - urn:iho:s:122:ed-1.0.0:appendix-D:2       IHO S-122 1.0.0 Appendix D-2
    # - urn:iho:m:2:sup-1                         IHO M-2 Sup 1
    # - urn:iho:p:5:vol-2024                      IHO P-5 Vol. 2024
    # - urn:iho:p:1:vol-30:issue-2                IHO P-1 Vol. 30 (2)
    class UrnGenerator
      attr_reader :identifier

      def initialize(identifier)
        @identifier = identifier
      end

      # [component, marker] pairs in the containment/canonical-face
      # order. A component edition/year emits right after its component
      # (the ed- segment attaches to the node it follows, recording the
      # separately-published mode). nil markers emit their component as
      # a BARE atom (the appendix subnumber directly after its
      # appendix).
      SEGMENTS = [
        [:edition, "ed"], [:year, "year"],
        [:supplement, "sup"], [:supplement_edition, "ed"],
        [:supplement_year, "year"],
        [:part, "part"], [:part_edition, "ed"], [:part_year, "year"],
        [:annex, "annex"], [:annex_edition, "ed"], [:annex_year, "year"],
        [:appendix, "appendix"], [:appendix_subnumber, nil],
        [:appendix_edition, "ed"], [:appendix_year, "year"],
        [:volume, "vol"], [:issue, "issue"], [:volume_edition, "ed"],
        [:volume_year, "year"]
      ].freeze

      def generate
        parts = ["urn", "iho"]
        parts << identifier.class.type[:short].to_s.downcase
        parts << identifier.number.to_s
        parts.concat(component_segments)
        parts.join(":")
      end

      private

      def component_segments
        SEGMENTS.filter_map do |component, marker|
          value = identifier.public_send(component)
          next unless value

          marker ? "#{marker}-#{value}" : value.to_s
        end
      end
    end
  end
end
