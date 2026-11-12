module Pubid
  module DoiPfs
    # Human renderer, generated from the canonical template.
    class Renderer < ::Pubid::Renderers::Base
      def render(**_opts)
        "doi:#{@id.prefix}/#{@id.suffix}"
      end
    end
  end
end
