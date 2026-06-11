# frozen_string_literal: true

module Pubid
  module Idf
    # Human-readable renderer for IDF identifiers.
    #
    # Produces strings like:
    #   "IDF 125:1988"
    #   "IDF/AMD 1:2023"
    #   "IDF 125:1988/AMD 1:2023"
    #
    # The renderer is registered as the `:human` format in the IDF format
    # registry and invoked via `render(format: :human)`.
    class Renderer < ::Pubid::Renderers::Base
      def render(context: nil, **opts)
        id = @id

        case id
        when SupplementIdentifier
          render_supplement(id, opts)
        else
          render_single(id, opts)
        end
      end

      private

      def render_single(id, opts)
        [
          publisher_portion(id),
          number_portion(id, opts),
        ].join
      end

      def publisher_portion(id)
        [
          id.publisher.body,
          (id.typed_stage.abbreviation.empty? ? "" : "/#{id.typed_stage.abbreviation}"),
        ].join
      end

      def number_portion(id, opts)
        lang_single = opts[:lang_single] || false

        [
          (id.number ? " #{id.number.value}" : ""),
          (id.part ? "-#{id.part.value}" : ""),
          (id.subpart ? "-#{id.subpart.value}" : ""),
          (id.stage_iteration ? ".#{id.stage_iteration.value}" : ""),
          (id.date ? ":#{id.date.year}" : ""),
          language_portion(id, lang_single: lang_single),
        ].join
      end

      def language_portion(id, lang_single: false)
        return "" unless id.languages&.any?

        [
          "(",
          id.languages.map do |lang|
            lang.to_s(lang_single: lang_single)
          end.join(lang_single ? "/" : ","),
          ")",
        ].join
      end

      def render_supplement(id, opts)
        lang = opts[:lang] || :en
        lang_single = opts[:lang_single] || false
        with_edition = opts[:with_edition] || false

        [
          id.base_identifier.to_s(lang: lang, lang_single: lang_single,
                                   with_edition: with_edition),
          "/",
          id.typed_stage.abbreviation,
          " ",
          id.number.value,
          (id.date ? ":#{id.date.year}" : ""),
        ].join
      end
    end
  end
end
