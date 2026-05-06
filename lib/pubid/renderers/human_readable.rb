# frozen_string_literal: true

module Pubid
  module Renderers
    class HumanReadable < Base
      def render(context:, with_edition: false)
        parts = []
        parts << render_publisher_and_stage(context)
        parts << render_number_portion(context)
        parts << render_edition_portion(context) if with_edition
        result = parts.compact.join(" ")
        result << render_language_portion(context, with_edition: with_edition)
        result << " (all parts)" if @id.all_parts
        result
      end

      private

      def render_publisher_and_stage(context)
        pub_str = @id.publisher.render(context:) if @id.publisher
        stage_str = @id.typed_stage.render(context:) if @id.typed_stage

        if stage_str && !stage_str.empty?
          has_copub = @id.publisher&.copublished?
          sep = has_copub ? " " : "/"
          "#{pub_str}#{sep}#{stage_str}"
        else
          pub_str
        end
      end

      def render_number_portion(context)
        parts = []
        parts << @id.number.render(context:) if @id.number
        parts << "-#{@id.part.render(context:)}" if @id.part
        parts << "-#{@id.subpart.render(context:)}" if @id.subpart
        parts << ".#{@id.stage_iteration.render(context:)}" if @id.stage_iteration
        date_str = @id.date.render(context:) if @id.date && context.with_date
        parts << ":#{date_str}" if date_str
        parts.join
      end

      def render_edition_portion(context)
        @id.edition.render(context:) if @id.edition&.number
      end

      def render_language_portion(context, with_edition: false)
        return "" unless @id.languages&.any? && context.with_language_code != :none

        use_single = with_edition ? false : context.with_language_code == :single
        rendered = @id.languages.map do |l|
          l.render(context:, lang_single: use_single)
        end
        "(#{rendered.join(use_single ? '/' : ',')})"
      end
    end
  end
end
