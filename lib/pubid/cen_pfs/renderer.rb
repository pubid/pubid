module Pubid
  module CenPfs
    # Human renderer, generated from the canonical template.
    class Renderer < ::Pubid::Renderers::Base
      def render(**_opts)
        "EN #{@id.number}#{"-#{@id.part}" if @id.part}#{":#{@id.date.year}" if @id.date&.year}"
      end
    end
  end
end
