module Pubid
  module EtsiPfs
    # Human renderer, generated from the canonical template.
    class Renderer < ::Pubid::Renderers::Base
      def render(**_opts)
        f = render_fields(@id)
        "ETSI #{f[:type]} #{f[:number]}#{(" #{f[:minor]}") if f[:minor]}#{("#{f[:parts]}") if f[:parts]}#{f[:supplements]}#{if f[:version]; " V#{f[:version]}" elsif f[:edition]; " ed.#{f[:edition]}"; end}#{(" (#{f[:year]}-#{f[:month]})") if f[:year] && f[:month]}"
      end

      private

      # The field view: a supplement wrapper reads through to
      # the wrapped standard and carries the notation run
      # ("/A1/C1", outermost last); the fold's target renders
      # only outside the fold flag (the V/ed faces are mutually
      # exclusive by grammar).
      def render_fields(id)
        root = id
        run = +""
        while root.is_a?(Identifiers::Supplement)
          run.prepend("/#{root.supplement_notation}")
          root = root.base
        end
        {
          type: root.type,
          number: root.number,
          minor: root.minor,
          parts: root.parts.any? ? root.parts.map { |item| "-#{item}" }.join : nil,
          version: root.is_edition ? nil : root.version,
          edition: root.is_edition ? root.version : nil,
          year: root.year,
          month: root.month,
          supplements: run.empty? ? nil : run,
        }
      end
    end
  end
end
