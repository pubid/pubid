# frozen_string_literal: true

module Pubid
  module Tgpp
    # Base class for every 3GPP identifier AND the flavor's parse entry point —
    # mirrors Pubid::Jis::Identifier. Concrete identifiers under
    # Pubid::Tgpp::Identifiers descend from this class, so a parsed 3GPP id is
    # an instance of Pubid::Tgpp::Identifier.
    class Identifier < ::Pubid::Identifier
      # The dotted core (e.g. "23.207") kept as a string to preserve leading
      # zeros. `number` overrides the base Components::Code attribute.
      attribute :number, :string
      # Optional letter suffix directly after the number: "U", "dcs", "ext"…
      attribute :suffix, :string
      # 1–2 hyphen parts (e.g. "26.171-1", "29.198-04-1"); strings preserve any
      # zero-padding.
      # `initialize_empty` makes a part-less identifier hold `[]` on BOTH
      # construction paths: Builder always passes an array, but the serialized
      # hash carries no `parts` key, so from_hash used to leave it nil and the
      # two compared unequal — which silently broke `#matches?` (and so every
      # part-less relaton index lookup). It does not change the serialized
      # shape: lutaml omits an empty collection either way. See CLAUDE.md.
      attribute :parts, :string, collection: true, initialize_empty: true
      # Raw release token, stored verbatim: "REL-4", "Ph1", "UMTS",
      # "Release 2000".
      attribute :release, :string
      # Three-part version string, e.g. "2.0.0".
      attribute :version, :string

      # 3GPP's edition/version identity is split across `release` and
      # `version`. `version` is already in the default
      # `%i[date year edition version]` list; `release` is not, so it
      # survived without_parts untouched and leaked into an "all parts"
      # identity built via #to_all_parts.
      def self.all_parts_edition_keys
        super + %i[release]
      end

      # A nil `suffix` and an empty `parts` mean the document has neither:
      # `TS 29.198` is not `TS 29.198-04-1`, and `TR 00.01` is not
      # `TR 00.01U`. A stated list is not a prefix either.
      subset_strict :suffix, :parts

      # Polymorphic type map for lutaml::Model key_value (de)serialization.
      # Keys are the `pubid:3gpp:…` names produced by polymorphic_name (below).
      TGPP_TYPE_MAP = {
        "pubid:3gpp:technical-report" =>
          "Pubid::Tgpp::Identifiers::TechnicalReport",
        "pubid:3gpp:technical-specification" =>
          "Pubid::Tgpp::Identifiers::TechnicalSpecification",
      }.freeze

      key_value do
        map "_type", to: :_type, polymorphic_map: TGPP_TYPE_MAP
        map "number", to: :number
        map "suffix", to: :suffix
        map "parts", to: :parts
        map "release", to: :release
        map "version", to: :version
      end

      # Publisher token. A plain constant (not a `publisher` method) so it does
      # not shadow the inherited lutaml `publisher` attribute.
      PUBLISHER = "3GPP"

      # The auto-derived polymorphic name would be "pubid:tgpp:…" (from the
      # module constant). Force the "3gpp" segment so the `_type` tag matches
      # the relaton flavor name and TGPP_TYPE_MAP.
      def self.polymorphic_name
        super&.sub(/\Apubid:tgpp:/, "pubid:3gpp:")
      end

      # Rendering flag: whether to prefix the string with "3GPP ". Transient
      # (not serialized). #to_s sets it, renders, then resets it to false in an
      # ensure block, so a subsequent bare #render defaults to no publisher and
      # the flag never leaks past the to_s call that set it.
      attr_reader :with_publisher

      # The rendered document code, e.g. "29.198-04-1" (number+suffix+parts).
      def code
        result = "#{number}#{suffix}"
        result += parts.map { |p| "-#{p}" }.join if parts&.any?
        result
      end

      # Basic string representation. Delegates to the :human renderer. Default
      # omits the "3GPP " publisher token (matches the relaton index id);
      # `to_s(with_publisher: true)` emits the printed "3GPP TS …" form.
      def to_s(with_publisher: false, **opts)
        @with_publisher = with_publisher
        render(format: :human, **opts)
      ensure
        @with_publisher = false
      end

      # Parse a 3GPP identifier string into an identifier object.
      #
      # Let Parslet::ParseFailed propagate on a bad reference (matching ISO and
      # ETSI), so relaton-cli's `rescue Parslet::ParseFailed` fetch handler
      # catches it instead of a bare RuntimeError. The length guard keeps its
      # ArgumentError — that is a different failure (input too long, not
      # unparseable) and it is the ReDoS barrier.
      #
      # @param identifier [String] The 3GPP identifier string to parse
      # @return [Identifier] The appropriate identifier object
      def self.parse(identifier)
        unless identifier.is_a?(String)
          raise Pubid::Errors::InvalidInputError,
                Pubid::INPUT_NOT_A_STRING_MESSAGE
        end

        if identifier.length > Pubid::MAX_INPUT_LENGTH
          raise Pubid::Errors::InvalidInputError, Pubid::INPUT_TOO_LONG_MESSAGE
        end

        parsed = Pubid::Parg::Model.bound(:tgpp, identifier)
        Builder.build(parsed)
      end

      # The version run the grammar binds is `1*digit "." 1*digit "." 1*digit`,
      # whose named-tree materialization is per-digit `digit` nodes joined by
      # unnamed "." literals. The parsanol 1.3.111 edition-2 emission serialized
      # that tree as the node list alone — the dots were unnamed, so they never
      # reached the stored row, and ~89,000 published relaton-data-3gpp rows
      # carry `version: '[{digit: "3"}, {digit: "0"}, {digit: "0"}]'` (the
      # node list's inspect) where the document's version is `3.0.0`. Rendered
      # verbatim the row prints the node hashes and the print never re-parses
      # (the relaton corpus gate's Law 1a). Current parses are unaffected —
      # only deserialization of those legacy rows needs the assembly.
      #
      # The dots are lost information, so the segmentation is a deterministic
      # reconstruction, validated against the index's own clean rows (the
      # crawler wrote both forms per document): the release names the version
      # major for the legacy year-releases (REL-99 documents carry version
      # 3.x.y) and for `REL-<n>`; otherwise a two-digit leading pair wins when
      # it is a plausible major (the largest 3GPP release is REL-21) and a
      # leading zero is always the minor's. The residue — identical digit
      # tuples whose documents genuinely differ, e.g. `1.10.0` vs `11.0.0`
      # from `[1,1,0,0]` — is unrecoverable from the row; any 3-segment choice
      # still parses and round-trips.
      LEGACY_RELEASE_MAJORS = {
        # The 3GPP release numbering starts Release 1999 = version 3.x.y; the
        # earlier year-releases continue the ETSI sequence backwards.
        "REL-96" => "5", "REL-97" => "6", "REL-98" => "7", "REL-99" => "3",
        "UMTS" => "3", "Ph1" => "3", "Ph2" => "4"
      }.freeze

      def self.from_hash(data, options = {})
        super(normalize_legacy_tree_version(data), options)
      end

      # Assemble a legacy named-tree version emission (see
      # {Pubid::LegacyTreeValue}) back into the dotted scalar. Leaves every
      # other value untouched; answers nil when +value+ is not the emission.
      def self.assemble_legacy_tree_version(value, release)
        digits = LegacyTreeValue.digit_values(value)
        return nil unless digits

        major = release_major(release)
        if major
          head = digits[0, major.length].join
          rest = digits.drop(major.length)
          if head == major && rest.length.between?(2, 4)
            return assemble_version_segments(major, rest)
          end
        end

        assemble_version_segments(nil, digits)
      end

      # The version major a release row names, when the release spelling maps
      # to one ("REL-18" → "18", the legacy year-releases per the table).
      def self.release_major(release)
        return nil unless release.is_a?(::String)

        LEGACY_RELEASE_MAJORS.fetch(release) do
          release.match?(/\AREL-\d+\z/) ? release.delete_prefix("REL-") : nil
        end
      end

      # Split a digit run into the three version segments. +major+ pins the
      # first segment when the release names it; the run then carries the
      # minor and patch digits, which the observed corpus always splits as
      # two-digit-minor (`18.1.0`), one-digit-minor/two-digit-patch
      # (`8.1.10`-era rows do not occur) or singles (`3.0.0`).
      def self.assemble_version_segments(major, rest)
        if major
          case rest.length
          when 2 then "#{major}.#{rest[0]}.#{rest[1]}"
          when 3 then "#{major}.#{rest[0]}#{rest[1]}.#{rest[2]}"
          when 4 then "#{major}.#{rest[0]}#{rest[1]}.#{rest[2]}#{rest[3]}"
          end
        else
          case rest.length
          when 3 then rest.join(".")
          when 4
            pair = rest[0] + rest[1]
            if rest[0] == "0"
              "0.#{rest[1]}#{rest[2]}.#{rest[3]}"
            elsif pair.to_i <= 21
              "#{pair}.#{rest[2]}.#{rest[3]}"
            else
              "#{rest[0]}.#{rest[1]}#{rest[2]}.#{rest[3]}"
            end
          when 5 then "#{rest[0]}#{rest[1]}.#{rest[2]}.#{rest[3]}#{rest[4]}"
          else rest.join(".")
          end
        end
      end

      def self.normalize_legacy_tree_version(data)
        return data unless data.is_a?(::Hash)

        release = data["release"] || data[:release]
        assembled = assemble_legacy_tree_version(
          data["version"] || data[:version], release,
        )
        return data unless assembled

        out = data.dup
        out[data.key?("version") ? "version" : :version] = assembled
        out
      end
    end
  end
end
