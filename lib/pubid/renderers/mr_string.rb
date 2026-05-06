# frozen_string_literal: true

module Pubid
  module Renderers
    class MrString < Base
      def render(context: nil, **)
        parts = []
        parts << @id.mr_publisher
        parts << @id.mr_type
        parts << @id.mr_number_with_part
        parts << @id.mr_year
        parts.compact.join(".")
      end
    end
  end
end
