# frozen_string_literal: true

module Pubid
  module Itu
    # Base class for all ITU identifiers. Canonical name Pubid::Itu::Identifier.
    class Identifier < ::Pubid::Identifier
      # Parse an ITU identifier string into an identifier object.
      def self.parse(identifier)
        parsed = Parser.parse(identifier)
        Builder.build(parsed)
      rescue Parslet::ParseFailed => e
        raise "Failed to parse ITU identifier '#{identifier}': #{e.message}"
      end

      # Long-form ↔ ITU single-letter language code map. The parser produces
      # single-letter codes (E/F/S/R/A/C); API callers (e.g. metanorma-itu)
      # pass long-form (en/fr/es/ru/ar/zh). Storage is normalized to the
      # single-letter form. Languages with no canonical letter (e.g. "de")
      # pass through unchanged and produce no trailing suffix.
      LANGUAGES = {
        "fr" => "F", "es" => "S", "ru" => "R",
        "ar" => "A", "zh" => "C", "en" => "E",
        "F" => "F", "S" => "S", "R" => "R",
        "A" => "A", "C" => "C", "E" => "E"
      }.freeze

      attribute :sector, Pubid::Itu::Components::Sector
      attribute :series, Pubid::Itu::Components::Series
      attribute :code, Pubid::Itu::Components::Code
      attribute :date, Pubid::Components::Date
      attribute :language, :string

      def initialize(**kwargs)
        if kwargs[:language]
          kwargs = kwargs.merge(language: normalize_language(kwargs[:language]))
        end

        super

        validate_ob_no_sector!
      end

      # The document number lives on the `code` component for ITU; surface it at
      # the identifier root so consumers that key on `#number` — e.g.
      # Relaton::Index's sort/bsearch narrowing on `id.root.number.to_s` — work
      # without special-casing ITU. Returns the `code.number` string (e.g.
      # "530"); serialization is unaffected because the flat key_value block
      # maps "number" via `number_to_kv`/`number_from_kv`, which read/write
      # `code.number` directly and never touch the inherited `number` attribute.
      # Supplement/Amendment/Corrigendum/Errata declare their own `:string`
      # `number` (the ordinal), which overrides this reader; their base document
      # number is still reachable via `root.number`.
      def number
        code&.number
      end

      # Generate URN for this identifier
      #
      # @return [String] URN representation

      # ITU encodes identity across `sector` (T/R/CD), `series` (G/H/J…), and
      # `code` (number with optional part), not in the inherited `number`/
      # `typed_stage`. The generic MrString renderer would otherwise drop all
      # three and emit just `ITU`. Losslessness for issue #142 requires the
      # sector letter, series letter, and document number to appear in MR.
      # Lowercased to match the all-lowercase MR convention.
      def mr_publisher
        publisher&.to_s&.downcase
      end

      def mr_type
        sector&.sector&.to_s&.downcase
      end

      def mr_number_with_part
        segments = []
        segments << series&.series&.to_s&.downcase if series&.series
        segments << code&.number&.to_s if code&.number
        segments << code&.subseries&.to_s if code&.subseries
        segments.concat(code&.parts&.map(&:to_s) || [])
        return nil if segments.empty?

        segments.join("-")
      end

      # Stored as a plain string (always "ITU") so it round-trips through
      # to_hash/from_hash. Was a `def publisher` method, which made lutaml
      # serialize a String against the Components::Publisher attribute.
      attribute :publisher, :string, default: -> { "ITU" }

      # Render identifier as a string.
      #
      # @param i18n_lang [Symbol, String] language for identifier text
      #   translation (e.g. :fr renders "Annex to" as "Annexe au"). Distinct
      #   from the identifier's `language` attribute, which is the document's
      #   own language and produces the trailing suffix like "-F".
      # @param language [Symbol, String] deprecated alias for i18n_lang.
      # @param format [Symbol] :long for title-style rendering of supported
      #   identifiers, otherwise the default short form.
      def to_s(**opts)
        opts = self.class.normalize_to_s_opts(opts)
        render_base(**opts) + render_language_suffix
      end

      def render_base(**_opts)
        result = "#{publisher}-#{sector}"

        # Add series and code
        result += if series
                    " #{series}.#{code}"
                  else
                    " #{code}"
                  end

        # Add date if present
        if date
          result += if date.month
                      " (#{date.month}/#{date.year})"
                    else
                      " (#{date.year})"
                    end
        end

        result
      end

      def render_language_suffix
        return "" unless language
        # Only render canonical single-letter ITU language codes
        # (e.g. "F", "S"). Languages with no mapping (e.g. "de") get
        # no suffix — matches v1 PR #38 render_language behavior.
        return "" unless LANGUAGES.value?(language)

        "-#{language}"
      end

      # Translate `language:` opt to `i18n_lang:` opt. v1 PR #38 introduced
      # `i18n_lang:` to disambiguate "rendering language" from the document
      # language attribute; `language:` remains a deprecated alias.
      def self.normalize_to_s_opts(opts)
        opts = opts.dup
        if opts.key?(:language) && !opts.key?(:i18n_lang)
          opts[:i18n_lang] = opts.delete(:language)
        else
          opts.delete(:language)
        end
        opts
      end

      def ==(other)
        return false unless other.is_a?(Pubid::Itu::Identifier)

        sector == other.sector &&
          series == other.series &&
          code == other.code &&
          date == other.date &&
          language == other.language
      end

      # --- Compact flat key_value converters (shared) --------------------
      # Collapse the identity components (Sector/Series/Code/Date) to bare
      # top-level scalars so the serialized hash is flat and index-friendly,
      # mirroring ISO/ETSI/JCGM/OIML. Used by the per-leaf key_value blocks
      # (see StandardSerialization) and by the Supplement/Annex/Combined
      # blocks. `publisher` ("ITU") is intentionally never mapped — it is
      # reconstructed from its attribute default.

      def sector_to_kv(model, doc)
        emit_kv(doc, "sector", model.sector&.sector)
      end

      def sector_from_kv(model, value)
        model.sector = Components::Sector.new(sector: value.to_s)
      end

      def series_to_kv(model, doc)
        emit_kv(doc, "series", model.series&.series)
      end

      def series_from_kv(model, value)
        model.series = Components::Series.new(series: value.to_s)
      end

      def imp_marker_to_kv(model, doc)
        emit_kv(doc, "imp_marker", model.code&.imp_marker)
      end

      def imp_marker_from_kv(model, value)
        code_for(model).imp_marker = value.to_s
      end

      def number_to_kv(model, doc)
        emit_kv(doc, "number", model.code&.number)
      end

      def number_from_kv(model, value)
        code_for(model).number = value.to_s
      end

      def series_suffix_to_kv(model, doc)
        emit_kv(doc, "series_suffix", model.code&.series_suffix)
      end

      def series_suffix_from_kv(model, value)
        code_for(model).series_suffix = value.to_s
      end

      def subseries_to_kv(model, doc)
        emit_kv(doc, "subseries", model.code&.subseries)
      end

      def subseries_from_kv(model, value)
        code_for(model).subseries = value.to_s
      end

      def parts_to_kv(model, doc)
        parts = model.code&.parts
        return if parts.nil? || parts.empty?

        doc.add_child(
          Lutaml::KeyValue::DataModel::Element.new("parts", parts.map(&:to_s)),
        )
      end

      def parts_from_kv(model, value)
        code_for(model).parts = Array(value).map(&:to_s)
      end

      def year_to_kv(model, doc)
        emit_kv(doc, "year", model.date&.year)
      end

      def year_from_kv(model, value)
        date_for(model).year = value.to_s
      end

      def month_to_kv(model, doc)
        emit_kv(doc, "month", model.date&.month)
      end

      def month_from_kv(model, value)
        date_for(model).month = value.to_s
      end

      # Serialize a nested `base` identifier via its own to_hash so it collapses
      # to the compact shape, and re-dispatch through the flavor base on load so
      # `_type` resolves to the concrete subclass (a bare polymorphic cast would
      # rebuild a plain Identifier and lose the subclass). Mirrors ETSI/JCGM.
      def base_to_kv(model, doc)
        return unless model.base

        doc.add_child(
          Lutaml::KeyValue::DataModel::Element.new("base", model.base.to_hash),
        )
      end

      def base_from_kv(model, value)
        return unless value

        model.base = Pubid::Itu::Identifier.from_hash(value)
      end

      def emit_kv(doc, key, value)
        return if value.nil? || value.to_s.empty?

        doc.add_child(
          Lutaml::KeyValue::DataModel::Element.new(key, value.to_s),
        )
      end

      def code_for(model)
        model.code ||= Components::Code.new
      end

      def date_for(model)
        model.date ||= Pubid::Components::Date.new
      end

      private

      def normalize_language(value)
        str = value.to_s
        LANGUAGES[str] || str
      end

      # OB (Operational Bulletin) is a cross-bureau ITU publication and
      # must not have a sector. Direct construction with both raises;
      # the parser silently drops sector for legacy strings like
      # "ITU-T OB.X" (handled in Builder).
      def validate_ob_no_sector!
        return unless series&.series == "OB"
        return if sector.nil?
        return if sector.is_a?(Components::Sector) && (sector.sector.nil? || sector.sector.to_s.empty?)

        raise ArgumentError,
              "OB (Operational Bulletin) is a cross-bureau ITU publication; " \
              "sector must not be set"
      end
    end

  end
end
