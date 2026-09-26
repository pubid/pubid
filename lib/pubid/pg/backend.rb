# frozen_string_literal: true

module Pubid
  module Pg
    # The PG-artifact parse backend: runs the flavor's baked artifact on
    # an input and returns the builder-ready attribute hash the flavor's
    # Builder expects — the same hash its parslet parser produced.
    module Backend
      LEAF_KEYS = %i[value line column offset length].freeze

      module_function

      def parse(flavor, input, entry: "identifier")
        shape = Artifact.for(flavor).parse(entry, input)
        to_builder_hash(shape)
      rescue Parsanol::ParseFailed => e
        raise Pubid::Errors::ParseError.new(e.message, nil,
                                            input: input,
                                            flavor: flavor.to_s)
      end

      # The artifact emits the parsanol-tree wire shape: capture leaves
      # ({value, line, column, offset, length}) carry their text, and the
      # top-level sequence is a list of capture hashes. The builder-ready
      # form scalarizes leaves and folds that top-level list into one
      # attribute hash (last key wins) — parslet's sequence fold.
      def to_builder_hash(shape)
        normalized = normalize(shape)
        return normalized.reduce(:merge) if mergeable_sequence?(normalized)

        normalized
      end

      def normalize(node)
        case node
        when Hash
          return node[:value] if leaf?(node)

          node.transform_values { |value| normalize(value) }
        when Array
          node.map { |item| normalize(item) }
        else
          node
        end
      end

      def mergeable_sequence?(value)
        value.is_a?(Array) && value.all?(Hash)
      end

      def leaf?(node)
        node.size == LEAF_KEYS.size && LEAF_KEYS.all? { |key| node.key?(key) }
      end
    end
  end
end
