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
        # version/date are optional on partial references; append each only when
        # present so a partial id renders without a stray " V… ()" suffix.
        result += " #{id.version}" if id.version
        result += " (#{id.date.render})" if id.date
        result
      end

      def render_supplement(id)
        supplement_notations = id.collect_supplement_notations(id, [])
        actual_base = id.find_actual_base(id.base)
        code_with_supplements = "#{actual_base.code}#{supplement_notations.join}"
        result = "#{actual_base.publisher} #{actual_base.type} #{code_with_supplements}"
        result += " #{actual_base.version}" if actual_base.version
        result += " (#{actual_base.date.render})" if actual_base.date
        result
      end
    end
  end
end
