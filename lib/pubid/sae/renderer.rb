# frozen_string_literal: true

module Pubid
  module Sae
    # Human-readable renderer for SAE identifiers.
    #
    # Produces strings like:
    #   "SAE AS5553"
    #   "SAE ARP4754A"
    #   "SAE AMS2475:2023"
    #
    # The renderer is registered as the +:human+ format in the SAE format
    # registry and invoked via +render(format: :human)+.
    class Renderer < ::Pubid::Renderers::Base
      def render(context: nil, **_opts)
        id = @id

        parts = []

        # Publisher and type
        parts << id.publisher if id.publisher
        parts << id.type.to_s if id.type

        # Number
        parts << id.number.to_s if id.number

        result = parts.join(" ")

        # Date
        result += ":#{id.date.year}" if id.date

        result
      end
    end
  end
end
