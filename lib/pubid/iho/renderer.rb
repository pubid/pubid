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
    #   "IHO P-5 2024"
    #   "IHO P-1 Vol. 30 No. 1"
    #
    # The renderer is registered as the `:human` format in the IHO format
    # registry and invoked via `render(format: :human)`.
    class Renderer < ::Pubid::Renderers::Base
      # Attribute → the label printed before its value, in render order.
      # The grammar admits only one of version / year / volume[+issue].
      SEGMENTS = [
        [:appendix, "Ap. "],
        [:part, "Part "],
        [:annex, "Annex "],
        [:supplement, "Suppl "],
        [:year, ""],
        [:volume, "Vol. "],
        [:issue, "No. "],
        [:version, ""],
      ].freeze

      def render(context: nil, **opts)
        id = @id
        rendered = "#{id.publisher} #{id.class.type[:short]}-#{id.number}"
        SEGMENTS.each do |attr, label|
          value = id.public_send(attr)
          rendered << " #{label}#{value}" if value
        end
        rendered
      end
    end
  end
end
