# frozen_string_literal: true

module Pubid
  module Renderers
    # Adds semantic <span class="..."> markers to an already-rendered
    # identifier string.
    #
    # In pubid 1.x annotation was applied in ONE place — `prerender_params`
    # wrapped every value in the param hash — so all 40-odd flavors got it for
    # free. pubid 2 replaced that hash with typed components and per-flavor
    # renderers, and the annotation went with it: `Renderers::Base#annotate`
    # exists, but only the HumanReadable family calls it. All 39 flavor
    # renderers receive `context.annotated` and ignore it, so
    # `to_s(annotated: true)` returned plain text for every flavor but ISO.
    #
    # Re-annotating inside 39 renderers would mean 39 chances to drift. This
    # class recovers the markup from the OUTSIDE instead: it asks the
    # identifier for its own component values and wraps each one where it
    # appears in the rendered string. That is one implementation, and a flavor
    # added tomorrow is covered without touching its renderer.
    #
    # It is a fallback, not a replacement. `Identifier#render` uses it only
    # when the renderer produced no span of its own, so ISO's exact,
    # render-time placement still wins.
    #
    # Deliberate limits:
    #
    # * A token that does not appear verbatim in the output is skipped. A
    #   renderer may transform a value (abbreviate it, change its case), and a
    #   missing span is a far better outcome than a wrong one or a crash.
    # * Matching walks left to right behind a cursor, so a later token can
    #   never match text an earlier one already claimed — that is what stops
    #   the part "1" of `ISO 1234-1` from matching inside "1234".
    class Annotator
      # Semantic class for each token, in the order tokens appear in a printed
      # identifier. Order matters: it is the sequence the cursor walks.
      TOKENS = [
        [:publisher, "publisher"],
        [:copublishers, "publisher"],
        %i[typed_stage typed_stage_css],
        [:type, "doctype"],
        [:stage, "stage"],
        [:number, "docnumber"],
        [:part, "part"],
        [:subpart, "part"],
        [:stage_iteration, "iteration"],
        [:year, "year"],
        [:edition, "edition"],
        [:languages, "language"],
      ].freeze

      # Characters that may not sit directly against a match, so a token never
      # binds to the middle of a longer run of the same character class.
      WORD_CHAR = /[A-Za-z0-9]/

      def initialize(identifier, context = nil)
        @id = identifier
        @context = context
      end

      # @param rendered [String] the plain rendering of {@id}
      # @return [String] the same string with semantic spans inserted
      def annotate(rendered)
        return rendered unless rendered.is_a?(String) && !rendered.empty?

        cursor = 0
        result = +""

        ordered_tokens(rendered).each do |text, css_class|
          index = find_token(rendered, text, cursor)
          next if index.nil?

          result << rendered[cursor...index]
          result << %(<span class="#{css_class}">#{text}</span>)
          cursor = index + text.length
        end

        result << rendered[cursor..]
        result
      end

      private

      # Tokens sorted by where they actually appear, not by the order
      # {TOKENS} lists them.
      #
      # Flavors disagree about layout: ISO prints the number before the type
      # ("ISO/IEC TR 2131"), CCSDS prints it after ("CCSDS 121.0-B-2"). Walking
      # in declaration order pushed the cursor past the number for CCSDS, so
      # "121" was never annotated. Sorting by first occurrence makes the walk
      # follow the printed identifier instead of a fixed idea of one.
      def ordered_tokens(rendered)
        tokens = []
        each_token { |text, css_class| tokens << [text, css_class] }

        decorated = tokens.each_with_index.map do |token, i|
          position = find_token(rendered, token.first, 0) || rendered.length
          [position, i, token]
        end

        decorated.sort_by { |position, i, _| [position, i] }.map(&:last)
      end

      # Yields [text, css_class] for every annotatable token this identifier
      # actually carries.
      def each_token
        TOKENS.each do |attr_name, css_class|
          Array(token_values(attr_name)).each do |value|
            text = token_text(value)
            next if text.nil? || text.empty?

            yield text, resolve_class(css_class, value)
          end
        end
      end

      def token_values(attr_name)
        return nil unless @id.respond_to?(attr_name)

        @id.public_send(attr_name)
      rescue StandardError
        # A derived reader may assume state a partial identifier lacks. A
        # missing span is not worth an exception on a rendering path.
        nil
      end

      # The printed form of one component. Components render themselves through
      # the context; a bare scalar is already its own text.
      def token_text(value)
        return nil if value.nil?

        text = if value.respond_to?(:render)
                 value.render(context: @context)
               else
                 value
               end
        text.to_s.strip
      rescue StandardError
        nil
      end

      def resolve_class(css_class, value)
        return css_class unless css_class == :typed_stage_css

        TypedStageClass.for(value)
      end

      # First occurrence of +text+ at or after +cursor+ that is not embedded in
      # a longer word — so "1" matches the part in "ISO 1234-1", never the "1"
      # inside "1234".
      def find_token(rendered, text, cursor)
        at = cursor
        while (index = rendered.index(text, at))
          return index if standalone?(rendered, index, text.length)

          at = index + 1
        end
        nil
      end

      def standalone?(rendered, index, length)
        before = index.zero? ? nil : rendered[index - 1]
        after = rendered[index + length]

        !WORD_CHAR.match?(before.to_s) && !WORD_CHAR.match?(after.to_s)
      end

      # The typed-stage class depends on the stage's type code, the same
      # mapping `Renderers::Base#typed_stage_css` applies. Kept here rather
      # than reached for through a private method on another object.
      module TypedStageClass
        MAP = {
          "amd" => "amendment",
          "cor" => "corrigendum",
          "add" => "addendum",
        }.freeze

        def self.for(typed_stage)
          code = typed_stage.respond_to?(:type_code) ? typed_stage.type_code.to_s : ""
          return "stage" if code.empty? || code == "is"

          MAP[code] || "doctype"
        end
      end
    end
  end
end
