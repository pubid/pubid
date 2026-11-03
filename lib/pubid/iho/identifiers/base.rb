# frozen_string_literal: true

module Pubid
  module Iho
    # Base class for all IHO identifiers. Canonical name Pubid::Iho::Identifier;
    # every concrete IHO identifier (Identifiers::*) descends from it.
    #
    # IHO identifiers have the form:
    #   IHO {S|P|M|B|C}-{number}[ {edition}| Vol. N [(issue)]]
    #       [ Sup N][ Part X][ Annex A][ Appendix B[-2]] [(2024)]
    #
    # Every tail component is a first-class semantic component: a typed
    # attribute, independently addressable, URN-encodable and matchable.
    # The canonical faces order the edition BEFORE the part
    # (`IHO S-100 1.0.0 Part 2`), print the supplement as "Sup" and the
    # appendix as "Appendix" (with the subnumber after a dash), the
    # volume issue parenthesized (`IHO P-1 Vol. 30 (2)`), and the
    # with-year qualifier parenthesized (`IHO S-100 5.0.0 Part 2 (2024)`
    # — the only year face: a periodical year IS a volume).
    class Identifier < ::Pubid::Identifier
      # Parse an IHO identifier string into an identifier object
      # @param identifier [String] The IHO identifier string to parse
      # @return [Pubid::Iho::Identifier] The appropriate identifier object
      # @raise [Pubid::Errors::ParseError] If parsing fails
      def self.parse(identifier)
        unless identifier.is_a?(String)
          raise Pubid::Errors::InvalidInputError,
                Pubid::INPUT_NOT_A_STRING_MESSAGE
        end

        if identifier.length > Pubid::MAX_INPUT_LENGTH
          raise Pubid::Errors::InvalidInputError, Pubid::INPUT_TOO_LONG_MESSAGE
        end

        parsed = Pubid::Parg::Model.bound(:iho, identifier.strip)
        Builder.build(parsed)
      end

      # `number` overrides the generic Components::Code attribute with a plain
      # string (same pattern as the other string components); it holds the IHO
      # document number (e.g. "100", "1/21" until the slash-chain volume
      # parse, "158:100"). Kept as the generic `number` so the relaton index
      # sorts/binary-searches on it natively via `id.number`.
      attribute :number,     :string
      attribute :publisher,  :string, default: "IHO"
      # The official IHO edition is the dotted x.y.z (a plain string — the
      # ~16 string-edition flavors precede this). `IHO S-100 1.0.0` is
      # edition-specific, `IHO S-100` edition-non-specific; a year beside an
      # edition is the with-year qualifier, never a year-keyed docidentifier.
      attribute :edition,    :string
      # The with-year qualifier on standards (`(2024)` beside an edition) —
      # the only year component. A periodical year IS a volume: the bare
      # legacy year input ("IHO P-5 2024") binds into `volume`, so this
      # attribute never carries a serial locator.
      attribute :year,       :string
      # Supplement, part, annex, appendix and volume are independently
      # publishable (owner ruling: "this can happen with any independently
      # publishable artifacts"), so each carries an optional edition (+ year
      # qualifier) of its own, mutually exclusive with the base edition
      # context: `IHO P-6 1.0.0 Vol. 2` (within-edition) vs
      # `IHO P-6 Vol. 2 1.0.1` (separately-published). The URN attaches
      # ed- to the node it follows, so one positional slot records both.
      attribute :supplement, :string
      attribute :supplement_edition, :string
      attribute :supplement_year,    :string
      attribute :part, :string
      attribute :part_edition, :string
      attribute :part_year,    :string
      attribute :annex, :string
      attribute :annex_edition, :string
      attribute :annex_year,    :string
      # The appendix is a letter or a number; a subnumbered appendix
      # ("Appendix D-2") keeps the letter in `appendix` and the "2" in
      # `appendix_subnumber` — two independently addressable components,
      # not one string.
      attribute :appendix, :string
      attribute :appendix_subnumber, :string
      attribute :appendix_edition,   :string
      attribute :appendix_year,      :string
      attribute :volume,     :string
      attribute :issue,      :string
      attribute :volume_edition, :string
      attribute :volume_year,    :string

      # Polymorphic type map for lutaml::Model key_value serialization: maps
      # each subclass's polymorphic_name to its class name so `from_hash` can
      # re-instantiate the concrete type from `_type`.
      IHO_TYPE_MAP = {
        "pubid:iho:standard" => "Pubid::Iho::Identifiers::Standard",
        "pubid:iho:publication" => "Pubid::Iho::Identifiers::Publication",
        "pubid:iho:miscellaneous" => "Pubid::Iho::Identifiers::Miscellaneous",
        "pubid:iho:bibliographic" => "Pubid::Iho::Identifiers::Bibliographic",
        "pubid:iho:circular-letter" => "Pubid::Iho::Identifiers::CircularLetter",
      }.freeze

      # The base Pubid::Identifier no longer auto-maps attributes, so each
      # flavor's top class must declare its own key_value mapping. IHO
      # attributes are plain strings, so they map directly. `publisher` is
      # intentionally omitted: it is always the "IHO" default and is restored
      # on load.
      key_value do
        map "_type",      to: :_type, polymorphic_map: IHO_TYPE_MAP
        map "number",     to: :number
        map "edition",    to: :edition
        map "year",       to: :year
        map "supplement",         to: :supplement
        map "supplement_edition", to: :supplement_edition
        map "supplement_year",    to: :supplement_year
        map "part",               to: :part
        map "part_edition",       to: :part_edition
        map "part_year",          to: :part_year
        map "annex",              to: :annex
        map "annex_edition",      to: :annex_edition
        map "annex_year",         to: :annex_year
        map "appendix",           to: :appendix
        map "appendix_subnumber", to: :appendix_subnumber
        map "appendix_edition",   to: :appendix_edition
        map "appendix_year",      to: :appendix_year
        map "volume",             to: :volume
        map "volume_edition",     to: :volume_edition
        map "volume_year",        to: :volume_year
        map "issue",              to: :issue
      end

      # from_hash is the shared polymorphic dispatch on Pubid::Identifier.
      # IHO_TYPE_MAP remains the key_value polymorphic_map.

      # The volume/issue and appendix/subnumber pairs are scalar clusters:
      # a reference that omits the finer component must still match a hit
      # that carries one ("P-1 Vol. 30" vs "P-1 Vol. 30 (2)"), so excluding
      # the coarser component nils the finer one with it — the same
      # additive-alias shape the base applies to :year -> :date. A lone
      # scalar :year needs no override here: the base nils a declared :year
      # directly (the additive :year -> :date alias nils whichever name the
      # flavor declares).
      def exclude(*args)
        args = args.dup
        args << :issue if args.include?(:volume)
        args << :appendix_subnumber if args.include?(:appendix)
        super
      end

      # Render the compact face: the code-adjacent components folded onto
      # the code with separators — the supplement and the part hyphenated
      # (`IHO M-2-2` for `IHO M-2 Sup 2`, `IHO S-5-B` for `IHO S-5 Part B`,
      # `IHO S-100-1` for `IHO S-100 Part 1`) and the volume as the slash
      # chain (`IHO P-5/2024` for `IHO P-5 Vol. 2024`). The canonical
      # render stays expanded; compact is opt-in. The legacy faces (glued
      # lettered bases, Suppl, bare years) parse but are never rendered in
      # any form.
      def render(format: :human, **opts)
        compact = opts.delete(:compact)
        result = super
        compact && format == :human ? compact_face(result) : result
      end

      # The shared mr_string path reads `edition&.number` (the base
      # declares edition as Components::Edition); IHO's edition is a plain
      # string, so the segment is built from it directly.
      def mr_edition
        return nil unless edition

        "ed#{edition}"
      end

      private

      # Fold " Sup N" / " Part X" / " Vol. N" into the code as "-N" /
      # "-X" / "/N", keeping everything else in place (the edition
      # follows the compact code, as in the legacy "S-5A 1.0.2" print
      # order). The issue keeps its parenthesized print.
      def compact_face(rendered)
        result = rendered.sub(/\A#{publisher} #{base_code}(?= |$)/,
                              "#{publisher} #{compact_code}")
        folded_segments.each { |segment| result = result.sub(segment, "") }
        result
      end

      def base_code
        "#{self.class.type[:short]}-#{number}"
      end

      def compact_code
        code = base_code.dup
        code << "-#{supplement}" if supplement
        code << "-#{part}" if part
        code << "/#{volume}" if volume
        code
      end

      def folded_segments
        [supplement && " Sup #{supplement}",
         part && " Part #{part}",
         volume && " Vol. #{volume}"].compact
      end
    end
  end
end
