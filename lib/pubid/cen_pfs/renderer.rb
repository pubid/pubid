module Pubid
  module CenPfs
    # Human renderer, generated from the canonical template.
    class Renderer < ::Pubid::Renderers::Base
      FACE_stage = {
        "fpren" => "FprEN",
        "pren" => "prEN",
      }.freeze
      def render(**_opts)
        f = render_fields(@id)
        "#{if f[:stage] && f[:number]; "#{f[:stage]} #{f[:number]}#{("-#{f[:part]}") if f[:part]}#{("#{f[:version]}") if f[:version]}#{(":#{f[:year]}") if f[:year]}" elsif f[:publisher] && f[:guide] && f[:number]; "#{f[:publisher]}#{("#{f[:copublishers]}") if f[:copublishers]} #{f[:guide]} #{f[:number]}#{("-#{f[:part]}") if f[:part]}#{(":#{f[:year]}") if f[:year]}" elsif f[:publisher] && f[:adopted]; "#{f[:publisher]}#{("#{f[:copublishers]}") if f[:copublishers]} #{f[:adopted]}" elsif f[:publisher] && f[:number]; "#{f[:publisher]}#{("#{f[:copublishers]}") if f[:copublishers]}#{("/#{f[:type]}") if f[:type]} #{f[:number]}#{("-#{f[:part]}") if f[:part]}#{("#{f[:version]}") if f[:version]}#{(":#{f[:year]}") if f[:year]}"; end}#{("#{f[:supplements]}#{(" FRAG#{f[:fragment_number]}") if f[:fragment_number]}") if f[:supplements]}"
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
        if root.is_a?(Identifiers::Fragment)
          frag = root.number
          root = root.base
        end
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
          copublishers: root.copublishers.to_a.any? ? root.copublishers.map { |item| "/#{item.respond_to?(:body) ? item.body : item}" }.join : nil,
          stage: FACE_stage.fetch(root.typed_stage&.code&.to_s, root.typed_stage&.code&.to_s),
          type: (v = root.type&.abbr) && ["TR", "TS"].include?(v) ? v : nil,
          guide: (v = root.type&.abbr) && ["Guide"].include?(v) ? v : nil,
          number: root.number,
          part: root.part,
          version: root.version,
          year: root.date&.year,
          adopted: root.respond_to?(:adopted) ? root.adopted : nil,
        }
        view[:supplements] = run.empty? ? nil : run
        view[:fragment_number] = frag
        view
      end
    end
  end
end
