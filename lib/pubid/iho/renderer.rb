# frozen_string_literal: true

module Pubid
  module Iho
    # Human-readable renderer for IHO identifiers.
    #
    # Produces strings like:
    #   "IHO S-44 5.0.0"
    #   "IHO P-1/21 1.0.0"
    #   "IHO S-100 Part 4a 1.0.0"
    #   "IHO S-65 Ap. A 1.0.0"
    #
    # The renderer is registered as the `:human` format in the IHO format
    # registry and invoked via `render(format: :human)`.
    class Renderer < ::Pubid::Renderers::Base
      def render(context: nil, **opts)
        id = @id

        letter = id.class.type[:short]
        rendered = "#{id.publisher} #{letter}-#{id.number}"
        rendered << " Ap. #{id.appendix}" if id.appendix
        rendered << " Part #{id.part}" if id.part
        rendered << " Annex #{id.annex}" if id.annex
        rendered << " Suppl #{id.supplement}" if id.supplement
        rendered << " #{id.version}" if id.version
        rendered
      end
    end
  end
end
