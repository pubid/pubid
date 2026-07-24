# frozen_string_literal: true

module Pubid
  module Isbn
    # Human-readable renderer for ISBN identifiers.
    #
    # Preserves the original hyphenation when present; otherwise emits the
    # bare digits. Always emits the "ISBN " prefix.
    class Renderer < ::Pubid::Renderers::Base
      def render(**_opts)
        body = @id.hyphenated || @id.raw
        "ISBN #{body}"
      end
    end
  end
end
