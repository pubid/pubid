# frozen_string_literal: true

module Pubid
  module Ietf
    # Human-readable renderer for IETF identifiers.
    #
    # Produces strings like:
    #   "RFC 2119"
    #   "BCP 3" / "STD 66" / "FYI 1"
    #   "draft-giuliano-treedn-02" / "draft-giuliano-treedn"
    class Renderer < ::Pubid::Renderers::Base
      def render(context: nil, **_opts)
        id = @id

        case id
        when Identifiers::Rfc
          "RFC #{id.number}"
        when Identifiers::InternetDraft
          id.version ? "#{id.name}-#{id.version}" : id.name
        else # Bcp/Std/Fyi sub-series
          "#{id.series} #{id.number}"
        end
      end
    end
  end
end
