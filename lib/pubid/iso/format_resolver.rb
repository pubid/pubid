# frozen_string_literal: true

module Pubid
  module Iso
    # Resolves format symbols to rendering options
    class FormatResolver
      FORMATS = {
        ref_num_short: {
          with_language_code: :single,      # 1-char: E, F, R, A, S, D
          stage_format_long: false,         # Short: DAM, COR, FDAM
          with_date: true,
        },
        ref_num_long: {
          with_language_code: :iso,         # 2-char: en, fr, ru, ar, es, de
          stage_format_long: true,          # Long: DAmd, Cor, FDAmd
          with_date: true,
        },
        ref_dated: {
          with_language_code: :none,
          stage_format_long: false,
          with_date: true,
        },
        ref_dated_long: {
          with_language_code: :none,
          stage_format_long: true,
          with_date: true,
        },
        ref_undated: {
          with_language_code: :none,
          stage_format_long: false,
          with_date: false,
        },
        ref_undated_long: {
          with_language_code: :none,
          stage_format_long: true,
          with_date: false,
        },
      }.freeze

      def self.resolve(format)
        FORMATS[format] || raise(ArgumentError, "Unknown format: #{format}")
      end
    end
  end
end
