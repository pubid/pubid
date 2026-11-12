module Pubid
  module CalconnectPfs
    # Human renderer, generated from the canonical template.
    class Renderer < ::Pubid::Renderers::Base
      def render(**_opts)
        "CC#{"/#{@id.series}" if @id.series} #{@id.number}#{":#{@id.date.year}#{"-#{@id.date.month}-#{@id.date.day}" if @id.date&.month && @id.date&.day}" if @id.date&.year}"
      end
    end
  end
end
