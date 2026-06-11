# frozen_string_literal: true

module Pubid
  module Itu
    module Identifiers
      # Base class for all ITU identifiers
      class Base < Pubid::Identifier
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

        # Generate URN for this identifier
        #
        # @return [String] URN representation

        # Override base_hash to handle ITU-specific attributes
        def base_hash
          hash = super
          # ITU Series has a 'series' attribute, not 'number'
          if hash[:series].is_a?(Hash) && series
            hash[:series] = series.series
          end
          # Add sector (ITU-specific, has a 'sector' attribute)
          hash[:sector] = sector.sector if sector
          hash
        end

        def publisher
          "ITU"
        end

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
          return false unless other.is_a?(Base)

          sector == other.sector &&
            series == other.series &&
            code == other.code &&
            date == other.date &&
            language == other.language
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
end
