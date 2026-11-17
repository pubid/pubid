module Pubid
  module BsiPfs
    # Human renderer, generated from the canonical template.
    class Renderer < ::Pubid::Renderers::Base
      # The designation faces (the typed trio): the token that
      # selected the class prints where the face names the
      # publisher — the column keeps the organization default.
      DESIGNATION_FACES = ["PAS", "PD", "DD", "TS"].freeze

      def render(**_opts)
        f = render_fields(@id)
        "#{if f[:publisher] && f[:adopted]; "#{f[:publisher]} #{f[:adopted]}" elsif f[:publisher] && f[:number]; "#{f[:publisher]} #{f[:number]}#{("-#{f[:part]}") if f[:part]}#{(":#{f[:year]}") if f[:year]}"; end}#{("#{f[:supplements]}") if f[:supplements]}"
      end

      private

      # The adoption face: the adopted document, with the
      # wrapper's own edition face after it (the declared glued
      # ED form — the hook lifts the ordinal onto the wrapper).
      def view_adopted(root)
        adopted = root.respond_to?(:base) ? root.base : nil
        return nil unless adopted

        edition = root.edition
        edition ? "#{adopted} ED#{edition}" : adopted.to_s
      end

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
          publisher: (t = root.type&.abbr) && DESIGNATION_FACES.include?(t) ? t : (root.publisher&.respond_to?(:body) ? root.publisher.body : root.publisher),
          number: root.number,
          part: root.part,
          year: root.date&.year,
          adopted: view_adopted(root),
        }
        view[:supplements] = run.empty? ? nil : run
        view
      end
    end
  end
end
