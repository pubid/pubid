# frozen_string_literal: true

module Pubid
  module Doi
    # Human-readable renderer for DOIs. Produces the canonical "doi:PREFIX/SUFFIX"
    # form (RFC 5650 §2).
    class Renderer < ::Pubid::Renderers::Base
      def render(**_opts)
        "doi:#{@id.prefix}/#{@id.suffix}"
      end
    end
  end
end
