# frozen_string_literal: true

module Pubid
  module Xsf
    # Human-readable renderer for XSF identifiers.
    #
    # Produces strings like "XEP 0001". With `with_publisher: false` it emits
    # just the bare number ("0001").
    #
    # Registered as the `:human` format in the XSF format registry and invoked
    # via `render(format: :human)`.
    class Renderer < ::Pubid::Renderers::Base
      PUBLISHER = "XEP"

      def render(context: nil, **opts)
        id = @id
        return id.number.to_s if id.with_publisher == false

        "#{PUBLISHER} #{id.number}"
      end
    end
  end
end
