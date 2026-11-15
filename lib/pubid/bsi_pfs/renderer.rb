module Pubid
  module BsiPfs
    # Human renderer, generated from the canonical template.
    class Renderer < ::Pubid::Renderers::Base
      def render(**_opts)
        f = render_fields(@id)
        "#{if f[:publisher] && f[:adopted]; "#{f[:publisher]} #{f[:adopted]}" elsif f[:publisher] && f[:number]; "#{f[:publisher]} #{f[:number]}#{("-#{f[:part]}") if f[:part]}#{(":#{f[:year]}") if f[:year]}"; end}#{("#{f[:supplements]}") if f[:supplements]}"
      end

      private

      # The field view: a wrapper reads through to the wrapped
      # standard and composes the printed run once — the standalone
      # chain behind its slash, the consolidated members behind the
      # plus — and the fragment face follows its base.
      def render_fields(id)
        root = id
        run = +""
        members = nil
        frag = nil
        if root.is_a?(Identifiers::ConsolidatedIdentifier)
          base, *consolidated = root.identifiers
          members = consolidated
          root = base
        end
        while root.is_a?(Identifiers::Supplement)
          run.prepend("/#{root.supplement_notation}")
          root = root.base
        end
        members&.each do |member|
          run << "+#{member.supplement_notation}"
        end
        view = {
          publisher: root.publisher&.respond_to?(:body) ? root.publisher.body : root.publisher,
          number: root.number,
          part: root.part,
          year: root.date&.year,
          adopted: root.respond_to?(:adopted) ? root.adopted : nil,
        }
        view[:supplements] = run.empty? ? nil : run
        view
      end
    end
  end
end
