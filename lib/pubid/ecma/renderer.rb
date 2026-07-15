# frozen_string_literal: true

module Pubid
  module Ecma
    # Human-readable renderer for ECMA identifiers.
    #
    # Produces strings like:
    #   "ECMA-411"        standard
    #   "ECMA-418-1"      standard with part
    #   "ECMA TR/101"     technical report
    #   "ECMA MEM/1970"   memento
    #
    # With `with_publisher: false` the leading ECMA token is dropped, yielding
    # "-411" / "TR/101" / "MEM/1970". The edition is never rendered — it is
    # separate metadata carried only in `to_hash`.
    class Renderer < ::Pubid::Renderers::Base
      PUBLISHER = "ECMA"

      def render(context: nil, **opts)
        id = @id
        # Standard joins the publisher directly ("ECMA-411"); TR/MEM separate it
        # with a space ("ECMA TR/101"). type_prefix is nil only for standards.
        sep = id.type_prefix.nil? ? "" : " "
        core = id.type_prefix.nil? ? standard_core(id) : typed_core(id)
        with_publisher?(id) ? "#{PUBLISHER}#{sep}#{core}" : core
      end

      private

      # Standard: "-<number>[-<part>]".
      def standard_core(id)
        core = "-#{id.number}"
        id.part ? "#{core}-#{id.part}" : core
      end

      # Technical Report / Memento: "<TYPE>/<number>".
      def typed_core(id)
        "#{id.type_prefix}/#{id.number}"
      end

      def with_publisher?(id)
        id.with_publisher != false
      end
    end
  end
end
