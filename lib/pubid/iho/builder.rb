# frozen_string_literal: true

module Pubid
  module Iho
    # Build IHO identifier objects from the grammar's typed bound map.
    #
    # Parse goes through {Pubid::Parg::Model.bound} — the artifact's
    # `bindings identifier` block delivers every component as an
    # attribute-named scalar (type, number, checks_for, part, annex,
    # appendix, appendix_subnumber, supplement, edition,
    # edition_shorthand, year, volume, issue) — so the builder dispatches
    # the series letter to its concrete class and resolves two
    # grammar-level aliases:
    # - the S-100 "v1"/"v5.1" edition shorthand pads to the official
    #   dotted x.y.z edition ("1" -> "1.0.0", "5.1" -> "5.1.0");
    # - the S-158 draft-era spellings of the series-member designator
    #   (`S-158 Part S-102`, `S-158-S-102`, `S-158 Part 102`) rebind onto
    #   `checks_for` — the model of issue #774, where the colon form
    #   `S-158:102` is the primary designator and the member is a
    #   publication of its own, not a part.
    class Builder
      ATTRIBUTES = %i[number checks_for appendix appendix_subnumber part
                      annex supplement year volume issue
                      part_edition part_year supplement_edition
                      supplement_year annex_edition annex_year
                      appendix_edition appendix_year volume_edition
                      volume_year
                      spec spec_sub spec_variant spec_part
                      spec_section].freeze
      # The independently-publishable components' own editions; the
      # base edition context is mutually exclusive with them (owner
      # ruling on the two publication modes).
      COMPONENT_EDITIONS = %i[part_edition supplement_edition annex_edition
                              appendix_edition volume_edition].freeze
      # The S-158 series anchor: the only series the checks_for member
      # designator rides (issue #774 — the colon form `S-158:102` is the
      # S-158 series device; `S-44:5` has no such meaning and rejects).
      CHECKS_SERIES = "158"
      # The draft-era part-face spellings that rebind onto checks_for:
      # the expanded series reference ("Part S-102") and the bare member
      # number ("Part 102"). A lettered or compound part value ("Part A",
      # "Part 4a") is a genuine part face and never rebinds.
      CHECKS_SERIES_REF_RE = /\A[SPMBC]-(\d+)\z/.freeze
      CHECKS_NUMBER_RE = /\A\d+\z/.freeze
      # The S-4 anchor: the loose-leaf publication every spec citation
      # resolves through (bare "B-401" carries it implicitly).
      S4_TYPE = "S"
      S4_NUMBER = "4"
      # A citation letter is one of S-4's lettered Parts; the section
      # vocabulary (100-600, Part C 100-500) is theirs.
      SPEC_LETTERS = %w[A B C].freeze
      # Components an S-4 spec citation cannot carry: the citation is a
      # leaf of the Part, not a wrappable publication.
      SPEC_FOREIGN_COMPONENTS = %i[supplement annex appendix
                                   appendix_subnumber volume issue].freeze

      def build(parsed)
        hash = parsed.is_a?(Array) ? parsed.reduce({}, :merge) : parsed
        attrs = stringified_attrs(hash)
        resolve_spec_citation!(attrs)
        type = type_letter_from(hash, attrs)
        assert_spec_anchor!(attrs, type)
        resolve_checks_alias!(attrs, type)
        assert_edition_mode!(attrs)
        klass = Pubid::Iho.identifier_klass_for_type_letter(type)
        klass.new(**attrs)
      end

      def self.build(parsed)
        new.build(parsed)
      end

      class << self
        # The alias unification {Builder#build} applies at parse time also
        # runs on the deserialization path ({Identifier.from_hash}), so a
        # stored row or a legacy URN carrying the draft-era part model
        # decodes to the checks_for identity (issue #774). Pure function:
        # returns the given hash untouched when it carries no draft-era
        # part face, a normalized copy otherwise. The spelling face is
        # NOT restored here — a deserialized identifier renders the
        # canonical colon designator (equality/URN use the canonical
        # shape; only the parse path keeps the input's spelling).
        def normalize_checks_alias(data)
          return data unless data.is_a?(::Hash)

          part = data["part"] || data[:part]
          number = data["number"] || data[:number]
          checks = data["checks_for"] || data[:checks_for]
          type_key = data["_type"] || data[:_type]
          return data unless part && number == CHECKS_SERIES && !checks
          return data unless standard_type?(type_key)

          digits = checks_digits_of(part)
          return data unless digits

          hash = data.dup
          edition = hash["part_edition"] || hash[:part_edition]
          year = hash["part_year"] || hash[:part_year]
          if (hash["edition"] || hash[:edition]) && edition
            raise ArgumentError,
                  "duplicate edition: the base edition and the member " \
                  "edition #{edition} cannot both ride S-158:#{digits}"
          end
          hash.delete("part")
          hash.delete(:part)
          hash.delete("part_edition")
          hash.delete(:part_edition)
          hash.delete("part_year")
          hash.delete(:part_year)
          hash["checks_for"] = digits
          hash["edition"] ||= edition if edition
          hash["year"] ||= year if year
          hash
        end

        # The member number of a draft-era part face: the digits of a
        # series reference ("S-102") or of the bare number face ("102").
        def checks_digits_of(part)
          if (match = CHECKS_SERIES_REF_RE.match(part.to_s))
            match[1]
          elsif CHECKS_NUMBER_RE.match?(part.to_s)
            part.to_s
          end
        end

        private

        # The rebind applies to the standard family (the S series): the
        # member designator is a facet of the S-158 standard family.
        def standard_type?(type_key)
          type_key.nil? || type_key.to_s.end_with?("standard")
        end
      end

      private

      # The S-158 alias unification (issue #774). A bound checks_for
      # must ride the S-158 anchor. Otherwise a draft-era part face on
      # the S-158 family — a series reference ("Part S-102") or the
      # bare member number ("Part 102") — rebinds onto checks_for: the
      # member is a publication of its own, not a part. The edition
      # that follows the part face is the BASE edition (the parted-
      # mis-bind fix of issue #775), and the spelling face records the
      # part value as written so the render keeps the input's spelling
      # (facets-spelling-only; equality/URN use the canonical shape).
      def resolve_checks_alias!(attrs, type)
        return assert_checks_anchor!(attrs, type) if attrs[:checks_for]

        return unless type == S4_TYPE && attrs[:number] == CHECKS_SERIES

        digits = Builder.checks_digits_of(attrs[:part]) if attrs[:part]
        return unless digits

        edition = attrs.delete(:part_edition)
        year = attrs.delete(:part_year)
        if attrs[:edition] && edition
          raise ArgumentError,
                "duplicate edition: the base edition " \
                "#{attrs[:edition]} and the member edition #{edition} " \
                "cannot both ride S-158:#{digits}"
        end
        if attrs[:year] && year
          raise ArgumentError,
                "duplicate year: the base year #{attrs[:year]} and the " \
                "member year #{year} cannot both ride S-158:#{digits}"
        end
        attrs[:checks_for] = digits
        attrs[:checks_for_face] = attrs.delete(:part)
        attrs[:edition] ||= edition
        attrs[:year] ||= year
      end

      # The colon member designator is the S-158 series device: another
      # anchor cannot carry it (the grammar binds the shape for every
      # series; the anchor is semantic).
      def assert_checks_anchor!(attrs, type)
        return if type == S4_TYPE && attrs[:number] == CHECKS_SERIES

        raise ArgumentError,
              "the checks_for member designator is the S-158 series " \
              "device: #{type}-#{attrs[:number]}:#{attrs[:checks_for]} " \
              "cannot carry it"
      end

      # The citation captures resolve onto the model (see the grammar
      # header): the citation letter folds into `part` (a Part-rule
      # capture must agree), and the long form's spelled section becomes
      # the spec alone — beside a citation it only cross-checks the
      # citation's derived section ("Part B, Section 400, B-401" stores
      # spec 401; "Part B, Section 500, B-401" is rejected).
      def resolve_spec_citation!(attrs)
        letter = attrs.delete(:spec_part)
        spelled = attrs.delete(:spec_section)
        attrs[:part] = merge_citation_letter!(attrs[:part], letter) if letter
        apply_spelled_section!(attrs, spelled)
        assert_citation_shape!(attrs) if attrs[:spec]
      end

      def apply_spelled_section!(attrs, spelled)
        return if spelled.nil?
        return attrs[:spec] = spelled unless attrs[:spec]

        return if spelled == spec_section_of(attrs[:spec])

        raise ArgumentError,
              "the spelled section #{spelled} disagrees with the " \
              "citation #{attrs[:part]}-#{attrs[:spec]}"
      end

      def spec_section_of(spec)
        "#{spec[0]}00"
      end

      def merge_citation_letter!(part, letter)
        return letter if part.nil? || part == letter

        raise ArgumentError,
              "the citation letter #{letter} conflicts with part #{part}"
      end

      def assert_citation_shape!(attrs)
        assert_citation_letter!(attrs)
        assert_citation_leaf!(attrs)
      end

      def assert_citation_letter!(attrs)
        return if SPEC_LETTERS.include?(attrs[:part])

        raise ArgumentError,
              "an S-4 spec citation needs a lettered Part (A/B/C), " \
              "not #{attrs[:part].inspect}"
      end

      # The citation is a leaf of its Part: it carries no component
      # edition and none of the wrappable components.
      def assert_citation_leaf!(attrs)
        if attrs[:part_edition] || attrs[:part_year]
          raise ArgumentError,
                "a spec citation rides the S-4 edition, not a part edition"
        end

        foreign = attrs.slice(*SPEC_FOREIGN_COMPONENTS).compact.keys
        return if foreign.empty?

        raise ArgumentError,
              "an S-4 spec citation is a leaf of its Part and cannot " \
              "carry #{foreign.join(', ')}"
      end

      # The series letter: a bare citation branch parse has no series
      # capture, and its anchor is implicitly the S-4 publication (the
      # number binds with it).
      def type_letter_from(hash, attrs)
        type = stringify(hash[:type])
        return type if type

        raise ArgumentError, "unknown IHO series" unless attrs[:spec]

        attrs[:number] = S4_NUMBER
        S4_TYPE
      end

      def assert_spec_anchor!(attrs, type)
        return unless attrs[:spec]
        return if type == S4_TYPE && attrs[:number] == S4_NUMBER

        raise ArgumentError,
              "an S-4 spec citation requires the S-4 anchor: " \
              "#{type}-#{attrs[:number]} cannot carry spec #{attrs[:spec]}"
      end

      # The two publication modes are mutually exclusive: an identifier
      # is either within-edition (a base edition its components ride) or
      # separately-published (a component carries its own edition and
      # the base is cited edition-less).
      def assert_edition_mode!(attrs)
        return unless attrs[:edition]
        return unless COMPONENT_EDITIONS.any? { |key| attrs[key] }

        owned = attrs.slice(*COMPONENT_EDITIONS).compact.keys.join(", ")
        raise ArgumentError,
              "a base edition and a component edition are mutually " \
              "exclusive: #{owned} cannot ride edition #{attrs[:edition]}"
      end

      def stringified_attrs(hash)
        attrs = ATTRIBUTES.to_h { |key| [key, stringify(hash[key])] }
        attrs[:edition] = edition_from(hash[:edition], hash[:edition_shorthand])
        attrs.compact
      end

      # The official IHO edition is the dotted x.y.z; the "v1"/"v5.1"
      # shorthand is a parse-only alias that fills the same attribute.
      def edition_from(edition, shorthand)
        return stringify(edition) if edition

        pad_edition_shorthand(shorthand)
      end

      def pad_edition_shorthand(shorthand)
        return nil if shorthand.nil?

        major, minor = stringify(shorthand).split(".")
        "#{major}.#{minor || '0'}.0"
      end

      def stringify(value)
        return nil if value.nil?

        str = value.to_s
        str.empty? ? nil : str
      end
    end
  end
end

Pubid::Iho::Builder.prepend(Pubid::Builder::AllPartsWrap)
