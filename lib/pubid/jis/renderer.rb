# frozen_string_literal: true

module Pubid
  module Jis
    # Human-readable renderer for JIS identifiers.
    #
    # Produces strings like:
    #   "JIS A 0001:1999"
    #   "JIS TR Z 8301:2019"
    #   "JIS B 3700-11:1996/CORRIGENDUM 1:2002"
    #   "JIS K 2151:2004/EXPL"
    #
    # The renderer is registered as the `:human` format in the JIS format
    # registry and invoked via `render(format: :human)`.
    class Renderer < ::Pubid::Renderers::Base
      PUBLISHER = "JIS"

      def render(context: nil, **opts)
        id = @id

        case id
        when SupplementIdentifier
          render_supplement(id)
        when SingleIdentifier
          render_single(id)
        else
          render_base(id)
        end
      end

      private

      def with_publisher?(id)
        id.with_publisher != false
      end

      def render_base(id)
        result = "#{PUBLISHER} #{id.code}"
        result += ":#{id.year_with_reaffirmation}" if id.year
        result += "(#{id.language})" if id.language
        result += "（規格群）" if id.all_parts?
        result + id.symbol_suffix
      end

      def render_single(id)
        with_pub = with_publisher?(id)
        parts = []
        parts << PUBLISHER if with_pub
        parts << id.type_prefix if id.class.method_defined?(:type_prefix) && id.type_prefix
        result = parts.join(" ")
        result += " " if result.length.positive?
        result += id.code.to_s
        result += ":#{id.year_with_reaffirmation}" if id.year
        result += "(#{id.language})" if id.language
        result += "（規格群）" if id.all_parts?
        result += id.symbol_suffix
        result
      end

      def render_supplement(id)
        with_pub = with_publisher?(id)
        result = id.base.to_s(with_publisher: with_pub)
        result += "/#{id.supplement_notation}"
        result += id.symbol_suffix
        result
      end
    end
  end
end
