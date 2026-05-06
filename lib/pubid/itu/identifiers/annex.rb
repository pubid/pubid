# frozen_string_literal: true

require_relative "base"

module Pubid
  module Itu
    module Identifiers
      # "Annex to ..." identifier — the document IS the annex of a Special
      # Publication (e.g. an annex to ITU OB), not a sub-annex with a number.
      #
      # Three rendering forms (per v1 PR #38):
      #   * default (no i18n_lang): English structural, "Annex to ITU OB No. 1000"
      #   * short with i18n_lang: structural translation using `annex_to`
      #   * long with i18n_lang + format: :long: per-language `annex_long` template
      # Languages without an `annex_to` entry (fr/es/ru/zh) use the long
      # template for the short form too.
      class Annex < Base
        attribute :base, Base, polymorphic: true

        def to_urn
          # Annex URN: append :annex to the inner identifier's URN.
          base_urn = base&.to_urn
          return "urn:itu:annex" unless base_urn

          "#{base_urn}:annex"
        end

        def render_base(**opts)
          lang = opts[:i18n_lang]&.to_s
          long_template = lang && Pubid::Itu::I18N["annex_long"]&.fetch(lang,
                                                                        nil)

          if opts[:format] == :long && long_template
            return long_template % { number: base_number }
          end

          annex_translation = lang && Pubid::Itu::I18N["annex_to"]&.fetch(lang,
                                                                          nil)

          if annex_translation
            base_str = base_render(**opts)
            return "#{base_str} #{annex_translation}" if lang == "ar"

            return "#{annex_translation} #{base_str}"
          end

          if long_template
            return long_template % { number: base_number }
          end

          "Annex to #{base_render(**opts)}"
        end

        def ==(other)
          return false unless other.is_a?(Annex)

          base == other.base && language == other.language
        end

        private

        def base_render(**opts)
          base&.render_base(**opts) || ""
        end

        def base_number
          return code&.number if code

          base&.code&.number
        end
      end
    end
  end
end
