# frozen_string_literal: true

module Pubid
  module Xsf
    # Human-readable renderer for XSF identifiers.
    #
    # Produces strings like "XEP 0001". The `XEP` token is the series and is
    # always rendered.
    #
    # Registered as the `:human` format in the XSF format registry and invoked
    # via `render(format: :human)`.
    class Renderer < ::Pubid::Renderers::Base
      PUBLISHER = "XEP"

      def render(context: nil, **opts)
        id = @id
        "#{PUBLISHER} #{id.number}"
      end
    end
  end
end
