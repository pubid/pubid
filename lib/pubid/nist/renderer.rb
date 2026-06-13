# frozen_string_literal: true

module Pubid
  module Nist
    # Human-readable renderer for NIST identifiers.
    #
    # NIST supports multiple output formats (:full, :long, :abbreviated,
    # :short, :mr). Each series class defines public style methods
    # (to_short_style, to_mr_style, etc.) with series-specific formatting
    # logic, so this renderer delegates to those methods rather than
    # reimplementing them.
    #
    # Registered as the `:human` format in the NIST format registry and
    # invoked via `render(format: :human, nist_format: :short)`.
    class Renderer < ::Pubid::Renderers::Base
      # Render the identifier in the requested NIST format.
      #
      # @param context [Object, nil] rendering context (unused by NIST)
      # @param nist_format [Symbol, nil] NIST output format (:full, :long,
      #   :abbreviated, :abbrev, :short, :mr). Defaults to :short.
      # @return [String] formatted identifier string
      def render(context: nil, nist_format: nil, **_opts)
        id = @id

        effective_format = nist_format || :short
        effective_format = effective_format.to_sym if effective_format.is_a?(String)

        case effective_format
        when :full, :long
          id.public_send(:to_full_style)
        when :abbreviated, :abbrev
          id.public_send(:to_abbreviated_style)
        when :short
          id.public_send(:to_short_style)
        when :mr
          id.public_send(:to_mr_style)
        else
          id.public_send(:to_short_style)
        end
      end
    end
  end
end
