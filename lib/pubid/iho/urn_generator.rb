# frozen_string_literal: true

module Pubid
  module Iho
    # Generates URN strings for IHO identifiers.
    #
    # == The adopted IHO MRN guidance (owner ruling, 2026-11-25)
    #
    # The series the guidance gives a publication type emit the guidance
    # form (S-100WG4, "MRN Guidelines for IHO"; the guidance's own
    # examples are s57 / urn:mrn:iho:pub:spec:s57:3:1:supplement3 and —
    # IHO's printed S-98 metadata — urn:mrn:iho:pub:spec:s98:1.0.0):
    #
    #   urn:mrn:iho:pub:<type>:<name>[:<edition>][:<trailing atoms>...]
    #
    # - <type>: spec (S series, Standards and Specifications) / per
    #   (P series, periodic publications) / reg (M series, Miscellaneous
    #   Base Regulatory Publications). The B (Bibliographic) and C
    #   (Circular Letter) series have no guidance type code — until IHO
    #   assigns one they keep the legacy positional emission below.
    # - <name>: sNNN — the lowercase series letter + number. The S-158
    #   member joins the name segment hyphenated (the fleet extension of
    #   the guidance for compound publication numbers, keeping the
    #   edition in its canonical 4th position):
    #
    #     S-158 1.0.0      -> urn:mrn:iho:pub:spec:s158:1.0.0
    #     S-158:102 1.0.0  -> urn:mrn:iho:pub:spec:s158-102:1.0.0
    #
    # - <edition>: the bare dotted x.y.z, NOT ed-prefixed (the S-98
    #   precedent). Absent for an edition-non-specific reference.
    # - The trailing atoms carry the components the guidance's tail
    #   slots do not model: lowercase marker tokens, RFC 3986-safe,
    #   values case-preserved (identity law: part-A and part-a are
    #   distinct documents). A component's own edition rides as ed-
    #   right after it (the duality law); the Appendix subnumber
    #   hyphen-joins its appendix; the base with-year qualifier keeps
    #   its year- marker. The guidance's bare correction/clarification
    #   slots (the s57:3:1 form) are not modeled faces — never emitted.
    #
    # Examples (the guidance form):
    # - urn:mrn:iho:pub:spec:s44:5.0.0                    IHO S-44 5.0.0
    # - urn:mrn:iho:pub:spec:s100:5.0.0:year-2024:part-2  IHO S-100 5.0.0 Part 2 (2024)
    # - urn:mrn:iho:pub:spec:s122:1.0.0:appendix-D-2      IHO S-122 1.0.0 Appendix D-2
    # - urn:mrn:iho:pub:spec:s4:4.10.0:part-B:spec-401    IHO S-4 4.10.0 B-401
    # - urn:mrn:iho:pub:spec:s158-102:1.0.0               IHO S-158:102 1.0.0
    # - urn:mrn:iho:pub:reg:m2:sup-1                      IHO M-2 Sup 1
    # - urn:mrn:iho:pub:per:p5:vol-2024                   IHO P-5 Vol. 2024
    #
    # == The legacy positional scheme (the B/C emission; decodable for
    #    every series, never emitted for S/P/M)
    #
    # The pre-guidance positional grammar (containment-ordered, one
    # semantic atom per segment, marker = the lowercased human-face
    # token; ed- follows ISO's RFC 5141 precedent):
    #
    #   urn:iho:<type>:<number>[:ed-<x.y.z>][:year-<yyyy>]
    #     [:sup-<n>[:ed-<x.y.z>][:year-<yyyy>]]
    #     [:part-<X>[:ed-<x.y.z>][:year-<yyyy>]]
    #     [:spec-<n>[:specsub-<n>][:specvar-<X>]]
    #     [:annex-<A>[...]]
    #     [:appendix-<B>[:<sub>][...]]
    #     [:vol-<n>[:issue-<n>][...]]
    #     [:year-<yyyy>]
    #
    # Containment: part contains annexes, annex contains appendices, the
    # subnumber is a child atom of its appendix, the issue a child of its
    # volume. Letters are case-preserved. The volume carries every serial
    # locator — the yearbook year IS a volume (P-5 Vol. 2024 gives
    # vol-2024), so a periodical identifier has no year segment; the
    # year- segment exists only for the standards with-year qualifier.
    #
    # Examples (the legacy form):
    # - urn:iho:b:4:ed-2.19.0                     IHO B-4 2.19.0
    # - urn:iho:c:13:ed-1.0.0                     IHO C-13 1.0.0
    class UrnGenerator
      attr_reader :identifier

      def initialize(identifier)
        @identifier = identifier
      end

      # The guidance publication type per series letter. S = Standards
      # and Specifications -> spec (the owner ruling names the guidance
      # code explicitly); P = the periodic publications -> per; M =
      # Miscellaneous (Base Regulatory Publications) -> reg. B and C
      # have no guidance code (legacy emission until IHO assigns one).
      MRN_TYPES = { "S" => "spec", "P" => "per", "M" => "reg" }.freeze

      # The guidance-form trailing atoms in containment order — the same
      # order the legacy scheme prints them. The Appendix subnumber is
      # handled inline (it hyphen-joins its appendix, one compound
      # segment); the checks_for member rides the name segment.
      MRN_SEGMENTS = [
        [:year, "year"],
        [:supplement, "sup"], [:supplement_edition, "ed"],
        [:supplement_year, "year"],
        [:part, "part"], [:part_edition, "ed"], [:part_year, "year"],
        # the S-4 spec citation: a child of its part (the citation
        # letter rides the part- atom); the SECTION is NOT emitted —
        # derivable from the spec's hundreds digit.
        [:spec, "spec"], [:spec_sub, "specsub"], [:spec_variant, "specvar"],
        [:annex, "annex"], [:annex_edition, "ed"], [:annex_year, "year"],
        [:appendix, "appendix"], [:appendix_subnumber, nil],
        [:appendix_edition, "ed"], [:appendix_year, "year"],
        [:volume, "vol"], [:issue, "issue"], [:volume_edition, "ed"],
        [:volume_year, "year"]
      ].freeze

      # [component, marker] pairs of the legacy positional scheme, in the
      # containment/canonical-face order. A component edition/year emits
      # right after its component (the ed- segment attaches to the node
      # it follows, recording the separately-published mode). nil markers
      # emit their component as a BARE atom (the appendix subnumber
      # directly after its appendix).
      SEGMENTS = [
        [:edition, "ed"], [:year, "year"],
        [:supplement, "sup"], [:supplement_edition, "ed"],
        [:supplement_year, "year"],
        [:part, "part"], [:part_edition, "ed"], [:part_year, "year"],
        # the S-4 spec citation: a child of its part (the citation
        # letter rides the part- atom), the dotted sub and the
        # parenthesized variant its own children.
        [:spec, "spec"], [:spec_sub, "specsub"], [:spec_variant, "specvar"],
        [:annex, "annex"], [:annex_edition, "ed"], [:annex_year, "year"],
        [:appendix, "appendix"], [:appendix_subnumber, nil],
        [:appendix_edition, "ed"], [:appendix_year, "year"],
        [:volume, "vol"], [:issue, "issue"], [:volume_edition, "ed"],
        [:volume_year, "year"]
      ].freeze

      def generate
        letter = identifier.class.type[:short].to_s
        MRN_TYPES[letter] ? generate_mrn(MRN_TYPES[letter]) : generate_legacy
      end

      private

      # The guidance form: type, name (sNNN / s158-NNN), the bare dotted
      # edition, then the trailing atoms in containment order.
      def generate_mrn(mrn_type)
        parts = ["urn:mrn:iho:pub", mrn_type, mrn_name]
        parts << identifier.edition if identifier.edition
        parts.concat(mrn_segments)
        parts.join(":")
      end

      # The lowercase name form (the guidance's "s57"/"s98" spelling).
      # The S-158 member joins hyphenated so the edition stays in its
      # canonical 4th position: s158-102.
      def mrn_name
        name = +"#{identifier.class.type[:short].downcase}#{identifier.number}"
        name << "-#{identifier.checks_for}" if identifier.checks_for
        name
      end

      def mrn_segments
        MRN_SEGMENTS.filter_map do |component, marker|
          case component
          when :appendix
            value = identifier.appendix
            next unless value

            segment = +"appendix-#{value}"
            # the subnumber hyphen-joins its appendix (one compound
            # segment, RFC 3986-safe)
            segment << "-#{identifier.appendix_subnumber}" if
              identifier.appendix_subnumber
            segment
          when :appendix_subnumber
            next # compound-joined into its appendix segment above
          else
            value = identifier.public_send(component)
            next unless value

            "#{marker}-#{value}"
          end
        end
      end

      # The legacy positional form (B/C today; the shape every legacy
      # urn:iho: URN decodes from).
      def generate_legacy
        parts = ["urn", "iho"]
        parts << identifier.class.type[:short].to_s.downcase
        parts << identifier.number.to_s
        parts.concat(component_segments)
        parts.join(":")
      end

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
