# frozen_string_literal: true

module Pubid
  module Arxiv
    class Identifier < ::Pubid::Identifier
      # The archive of an old-form id (`hep-th`, `math`); nil for a new id.
      attribute :archive, :string

      # The subject class of an old-form id (`GT` in `math.GT/0309136`).
      attribute :subject_class, :string

      # The submission year (4 digits) and month, read from the id's YYMM.
      attribute :year, :integer
      attribute :month, :integer

      # The e-print version (`v2` -> 2); nil when the id names no version.
      attribute :version, :integer

      ARXIV_TYPE_MAP = {
        "pubid:arxiv:eprint" => "Pubid::Arxiv::Identifiers::Eprint",
      }.freeze

      key_value do
        map "_type", to: :_type, polymorphic_map: ARXIV_TYPE_MAP
        map "archive", to: :archive
        map "subject_class", to: :subject_class
        map "year", to: :year
        map "month", to: :month
        map "number", to: :number
        map "version", to: :version
      end

      # A nil archive or subject class means "this id has none", so a new id
      # never matches an old one and `math/…` never matches `math.GT/…`. The
      # year, month and number are always stated. The version is the only
      # wildcard.
      subset_strict :archive, :subject_class, :year, :month, :number

      # The year and month name the paper (they are its YYMM), not an
      # edition, so the generic year wildcard must not drop them:
      # `matches?(other, ignore: [:year])` would otherwise match
      # `2301.00001` with `2401.00001`.
      IDENTITY_ATTRIBUTES = %i[year date month].freeze

      def exclude(*attrs)
        super(*(attrs - IDENTITY_ATTRIBUTES))
      end

      # arXiv registers no official URN namespace, and the base fallback
      # (`urn:arxiv:<number>:<year>`) maps different papers to one URN, so
      # the official form is the lossless pubid-scheme URN.
      def to_urn
        to_pubid_urn
      end

      PUBLISHER = "arXiv"

      # The four-digit YYMM the id prints.
      def yymm
        format("%<yy>02d%<mm>02d", yy: year.to_i % 100, mm: month.to_i)
      end

      # True for an old-form (archive) id.
      def old_style?
        !archive.nil?
      end

      def to_s(**opts)
        render(format: :human, **opts)
      end

      # The renderer prints the `arXiv:` token itself and drops it for
      # `with_publisher: false`. The shared stripper cuts only before a space,
      # `-`, `/` or `.`, never before a colon, so it has nothing to cut here.
      def publisher_prefixes
        []
      end

      def self.parse(identifier)
        unless identifier.is_a?(String)
          raise Pubid::Errors::InvalidInputError,
                Pubid::INPUT_NOT_A_STRING_MESSAGE
        end

        if identifier.length > Pubid::MAX_INPUT_LENGTH
          raise Pubid::Errors::InvalidInputError, Pubid::INPUT_TOO_LONG_MESSAGE
        end

        identifier = ::Pubid.utf8_input(identifier)

        # The guards above stay OUTSIDE build_identifier, whose ArgumentError
        # rescue would otherwise swallow them (the ISBN lesson).
        build_identifier(identifier)
      end

      # @raise [Pubid::Errors::ParseError] if the string is not an arXiv id
      def self.build_identifier(identifier)
        parsed = Pubid::Parg::Model.bound(:arxiv, identifier)
        Builder.build(parsed)
      rescue ArgumentError => e
        # The Builder checks the date ranges, the month and the version.
        # Surface that as a parse failure, the class a grammar rejection has.
        raise Pubid::Errors::ParseError.new(
          "invalid arXiv identifier '#{identifier}': #{e.message}",
          input: identifier, flavor: "arxiv",
        )
      end
      private_class_method :build_identifier
    end
  end
end
