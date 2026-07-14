# frozen_string_literal: true

module Pubid
  module Tgpp
    # Human-readable renderer for 3GPP identifiers.
    #
    # Produces strings like:
    #   "TS 23.207:REL-4/2.0.0"                (default, no publisher)
    #   "3GPP TS 23.207:REL-4/2.0.0"           (with_publisher: true)
    #   "TS 29.198-04-1:REL-5/5.0.0"           (parts)
    #   "TR 00.01U:UMTS/3.0.0"                 (suffix)
    class Renderer < ::Pubid::Renderers::Base
      PUBLISHER = "3GPP"

      def render(context: nil, **_opts)
        id = @id
        head = []
        head << PUBLISHER if with_publisher?(id)
        head << id.type_prefix
        result = "#{head.join(' ')} #{id.code}"
        # A handful of legacy records omit the release segment entirely
        # (e.g. "TS 29.215/2.0.0").
        result += ":#{id.release}" if id.release
        "#{result}/#{id.version}"
      end

      private

      # Default is no publisher token (the relaton index id form); the caller
      # opts in via `to_s(with_publisher: true)`.
      def with_publisher?(id)
        id.with_publisher == true
      end
    end
  end
end
