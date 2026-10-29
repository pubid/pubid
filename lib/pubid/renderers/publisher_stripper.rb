# frozen_string_literal: true

module Pubid
  module Renderers
    # Removes the leading publisher token from an already-rendered identifier,
    # for `to_s(with_publisher: false)`.
    #
    # relaton#49 asks for an internal form of every identifier: the form an SDO
    # uses when it cites its own documents, with the publisher prefix dropped
    # (`NIST SP 800-113` -> `SP 800-113`). Teaching 40-odd flavor renderers to
    # omit the publisher would mean 40 chances to drift, and a flavor added
    # tomorrow would get nothing. This class works from the OUTSIDE instead,
    # the way {Annotator} does: the identifier names the prefixes its rendering
    # can start with (`Pubid::Identifier#publisher_prefixes`), and the prefix
    # is cut off together with the one separator that follows it.
    #
    # Deliberate limits:
    #
    # * A prefix must be followed by a separator (space, `-`, `/` or `.`), so
    #   `ISO` never cuts into `ISOFIX`.
    # * When no prefix matches, or cutting it would leave nothing, the input
    #   comes back unchanged: the option is ignored rather than producing a
    #   broken identifier.
    class PublisherStripper
      SEPARATOR = %r{\A(?:\s+|[-/.]\s*)}

      def initialize(identifier)
        @id = identifier
      end

      # A co-published group is not always joined by `/`: CIE prints
      # `CIE ISO 10916:2024`. The cut therefore repeats while a publisher
      # token still leads, so the group drops whole whatever its joiner.
      # The cap only guards against a cycle; no corpus id has more than three.
      MAX_CUTS = 4

      # @param rendered [String] the default human rendering of the identifier
      # @return [String] the rendering without its leading publisher token
      def strip(rendered)
        return rendered unless rendered.is_a?(String)

        candidates = prefixes
        MAX_CUTS.times do
          stripped = cut_once(rendered, candidates)
          break if stripped.equal?(rendered)

          rendered = stripped
        end
        rendered
      end

      private

      def cut_once(rendered, candidates)
        candidates.each do |prefix|
          next unless rendered.start_with?(prefix)

          rest = rendered[prefix.length..]
          next unless rest.match?(SEPARATOR)

          stripped = rest.sub(SEPARATOR, "")
          return stripped unless stripped.empty?
        end

        rendered
      end

      # Longest first, so `ISO/IEC` wins over `ISO`. Each prefix also comes in
      # its annotated spelling: ISO annotates inside its own renderer, so its
      # string already reads `<span class="publisher">ISO</span> …` when it
      # reaches this class.
      def prefixes
        Array(@id.publisher_prefixes)
          .map { |p| p.to_s.strip }
          .reject(&:empty?)
          .flat_map { |p| [%(<span class="publisher">#{p}</span>), p] }
          .uniq
          .sort_by { |p| -p.length }
      end
    end
  end
end
