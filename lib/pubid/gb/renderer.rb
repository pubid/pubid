# frozen_string_literal: true

module Pubid
  module Gb
    # Human-readable renderer for Chinese Standard identifiers.
    #
    # Produces the canonical printed form:
    #   "GB/T 20223-2006"
    #   "GB/T 5606.1-2004"
    #   "GB/T 5606 (all parts)"
    #   "T/GZAEPI 001—2018"     (social-group form, em-dash year)
    class Renderer < ::Pubid::Renderers::Base
      def render(**_opts)
        parts = [publisher_portion, " #{number_portion}"]
        parts << " (all parts)" if @id.all_parts
        parts.join
      end

      private

      def publisher_portion
        code = @id.publisher_code.to_s
        code += "/#{@id.mandate}" if @id.mandate && !@id.publisher_code.include?("/")
        code
      end

      def number_portion
        result = @id.number.to_s
        result += ".#{@id.part}" if @id.part
        result += "-#{@id.year}" if @id.year
        result
      end
    end
  end
end
