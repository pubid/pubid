module Pubid
  module EtsiPfs
    # Human renderer, generated from the canonical template.
    class Renderer < ::Pubid::Renderers::Base
      def render(**_opts)
        "ETSI #{@id.type} #{@id.number}"
      end
    end
  end
end
