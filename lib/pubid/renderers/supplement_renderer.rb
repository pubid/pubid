# frozen_string_literal: true

module Pubid
  module Renderers
    class SupplementRenderer < HumanReadable
      def render(context:, with_edition: false)
        parts = []

        base_str = @id.base_identifier.to_s(
          with_edition: with_edition,
          stage_format_long: context.stage_format_long,
          with_date: context.with_date,
        )

        stage_str = @id.typed_stage.render(context:)
        parts << "#{base_str}/#{stage_str}"

        num_port = render_number_portion(context)
        if num_port && !num_port.empty? && !num_port.start_with?(":")
          parts << (stage_str.end_with?(".") ? "" : " ")
        end
        parts << num_port

        parts << " #{render_edition_portion(context)}" if with_edition && @id.edition&.number
        if @id.languages&.any?
          parts << render_language_portion(context,
                                           with_edition: with_edition)
        end
        parts.compact.join
      end
    end
  end
end
