# frozen_string_literal: true

module Pubid
  module Iso
    class SingleIdentifier < Identifier
      def to_s(**opts)
        render(format: :human, **opts)
      end

      private

      def build_rendering_context(_renderer, format:, with_edition: false,
                                  lang: :en, lang_single: false,
                                  stage_format_long: nil, with_date: nil,
                                  annotated: false)
        if format == :mr_string
          nil
        elsif lang_single || stage_format_long || !with_date.nil?
          Rendering::RenderingContext.new(
            with_language_code: lang_single ? :single : :none,
            stage_format_long: stage_format_long || false,
            with_date: with_date.nil? || with_date,
            annotated: annotated,
          )
        else
          detect_rendering_context(annotated: annotated)
        end
      end

      def detect_rendering_context(annotated: false)
        Rendering::RenderingContext.new(
          with_language_code: detect_language_code_format,
          stage_format_long: detect_stage_format_long,
          with_date: true,
          annotated: annotated,
        )
      end

      def detect_stage_format_long
        return false unless typed_stage

        ts = typed_stage
        if ts.long_abbr && ts.original_abbr&.start_with?(ts.long_abbr)
          true
        elsif ts.long_abbr && ts.original_abbr&.include?("Directives")
          true
        else
          false
        end
      end

      def detect_language_code_format
        return :none unless languages&.any?

        first_lang = languages.first
        if first_lang.original_code && first_lang.original_code.length == 1
          :single
        else
          :iso
        end
      end
    end
  end
end
