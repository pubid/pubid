# frozen_string_literal: true

module Pubid
  module Etsi
    # Human-readable renderer for ETSI identifiers.
    #
    # Produces strings like:
    #   "ETSI EN 301 419 V1.1.1 (2020-01)"
    #   "ETSI TS 102 606-1/A1 V1.1.1 (2021-06)"
    #   "ETSI GS NFV 002 ed.1 (2013-10)"
    #
    # The renderer is registered as the `:human` format in the ETSI format
    # registry and invoked via `render(format: :human)`.
    class Renderer < ::Pubid::Renderers::Base
      def render(context: nil, **opts)
        id = @id

        case id
        when Identifiers::SupplementIdentifier
          render_supplement(id)
        else
          render_base(id)
        end
      end

      private

      def render_base(id)
        result = "#{id.publisher} #{id.type} #{id.code}"
        result += " #{id.version} (#{id.date.render})"
        result
      end

      def render_supplement(id)
        supplement_notations = id.collect_supplement_notations(id, [])
        actual_base = id.find_actual_base(id.base)
        code_with_supplements = "#{actual_base.code}#{supplement_notations.join}"
        "#{actual_base.publisher} #{actual_base.type} #{code_with_supplements} #{actual_base.version} (#{actual_base.date.render})"
      end
    end
  end
end
