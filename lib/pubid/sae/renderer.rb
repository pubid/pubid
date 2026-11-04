# frozen_string_literal: true

module Pubid
  module Sae
    # Human-readable renderer for SAE identifiers, in the form SAE prints:
    #
    #   "SAE J3016"            "SAE AMS4121J"
    #   "SAE J3016_202104"     "SAE ARP4754A:2010"
    #   "SAE AS22520/45A"      "SAE AMS-QQ-A-250/4B"
    #   "SAE AS5259/7A_A1"     "SAE USCAR-2-6"
    #
    # A dated edition with a month renders SAE's native edition code
    # (+_YYYYMM+); a year alone renders +:YYYY+.
    class Renderer < ::Pubid::Renderers::Base
      def render(context: nil, **_opts)
        id = @id
        type = id.type
        code = type ? "#{type.abbr}#{type.separator}" : ""
        result = [id.publisher, code + id.designation].compact.join(" ")
        result + date_suffix(id, context)
      end

      private

      def date_suffix(id, context)
        return "" unless id.date&.year

        separator = id.date.month ? "_" : ":"
        "#{separator}#{id.date.render(context:)}"
      end
    end
  end
end
