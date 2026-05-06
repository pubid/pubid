# frozen_string_literal: true

module Pubid
  module Renderers
    class DirectivesRenderer < HumanReadable
      def render(context:, with_edition: false)
        parts = []
        parts << render_publisher_portion(context)
        num_port = render_number_portion(context)

        if num_port && !num_port.empty?
          if num_port.start_with?(":")
            result = parts.compact.join(" ") + num_port
          else
            parts << num_port
            result = parts.compact.join(" ")
          end
        else
          result = parts.compact.join(" ")
        end

        result << " #{render_edition_portion(context)}" if with_edition && @id.edition&.number
        result << render_language_portion(context, with_edition: with_edition)
        result
      end

      private

      def render_publisher_portion(context)
        pub_str = @id.publisher.render(context:) if @id.publisher
        abbr = @id.typed_stage ? @id.typed_stage.abbreviation(format_long: false) : ""
        subgroup_str = @id.subgroup.render(context:) if @id.subgroup

        unless @id.publisher&.copublished?
          return [
            pub_str,
            (subgroup_str ? " #{subgroup_str}" : ""),
            (abbr.empty? ? "" : " #{abbr}"),
          ].join
        end

        [
          pub_str,
          (subgroup_str ? " #{subgroup_str}" : ""),
          (abbr.empty? ? "" : " #{abbr}"),
        ].join
      end

      def render_number_portion(context)
        parts = []
        parts << @id.number.render(context:) if @id.number
        parts << " #{@id.part.render(context:)}" if @id.part
        parts << "-#{@id.subpart.render(context:)}" if @id.subpart
        parts << ".#{@id.stage_iteration.render(context:)}" if @id.stage_iteration
        date_str = @id.date.render(context:) if @id.date && context.with_date
        parts << ":#{date_str}" if date_str
        result = parts.join.strip
        result.empty? ? nil : result
      end
    end
  end
end
