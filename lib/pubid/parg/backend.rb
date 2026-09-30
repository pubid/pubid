# frozen_string_literal: true

module Pubid
  module Parg
    # The PG-artifact parse backend: runs the flavor's baked artifact on
    # an input and returns the builder-ready attribute hash the flavor's
    # Builder expects — the same hash its parslet parser produced.
    module Backend
      LEAF_KEYS = %i[value line column offset length].freeze

      module_function

      ALL_PARTS_SUFFIX = "(all parts)"

      def parse(flavor, input, entry: "identifier", merge_top_sequence: true)
        # The parslet grammar base strips the "(all parts)" suffix before
        # parsing and marks the tree (Grammar#parse / #mark_all_parts);
        # the artifact backend carries the same contract so every flavor
        # whose grammar does not itself consume the suffix keeps working.
        if input.end_with?(ALL_PARTS_SUFFIX)
          base = input.sub(/\s*\(all parts\)\s*\z/, "")
          tree = to_builder_hash(Artifact.for(flavor).parse(entry, base), merge: merge_top_sequence)
          return mark_all_parts(tree)
        end

        to_builder_hash(Artifact.for(flavor).parse(entry, input), merge: merge_top_sequence)
      rescue Parsanol::ParseFailed => e
        raise Pubid::Errors::ParseError.new(e.message, nil,
                                            input: input,
                                            flavor: registered_name(flavor))
      end

      # The registered flavor name (Registry-resolvable; "3gpp" for
      # Pubid::Tgpp), falling back to the internal symbol when the
      # flavor is not registered.
      def registered_name(flavor)
        mod = Pubid.const_get(flavor.to_s.split("_").map(&:capitalize).join)
        names = Pubid::Registry.flavor_names.select { |name| Pubid::Registry.get(name) == mod }
        # A module may register under several names; the longest is the
        # canonical one ("cen_cenelec", not the "cen" alias).
        names.max_by(&:length)
      rescue NameError
        nil
      end || flavor.to_s

      def mark_all_parts(tree)
        case tree
        when Hash then tree.merge(all_parts: true)
        when Array then tree.map { |t| t.merge(all_parts: true) }
        else tree
        end
      end

      # The artifact emits the parsanol-tree wire shape: capture leaves
      # ({value, line, column, offset, length}) carry their text, and the
      # top-level sequence is a list of capture hashes. The builder-ready
      # form scalarizes leaves and folds that top-level list into one
      # attribute hash (last key wins) — parslet's sequence fold.
      def to_builder_hash(shape, merge: true)
        normalized = normalize(shape)
        return normalized.reduce(:merge) if merge && mergeable_sequence?(normalized)

        normalized
      end

      def normalize(node)
        case node
        when Parsanol::Slice then node.content
        when Hash then normalize_hash(node)
        when Array then node.map { |item| normalize(item) }
        else node
        end
      end

      def normalize_hash(node)
        return node[:value] if wire_leaf?(node)

        node.transform_values { |value| normalize(value) }
      end

      def mergeable_sequence?(value)
        value.is_a?(Array) && value.all?(Hash)
      end

      def wire_leaf?(node)
        return false unless node.size == LEAF_KEYS.size

        LEAF_KEYS.all? { |key| node.key?(key) }
      end
    end
  end
end
