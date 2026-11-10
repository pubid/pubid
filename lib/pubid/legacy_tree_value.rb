# frozen_string_literal: true

module Pubid
  # The digit-node emission of the parsanol 1.3.111 edition-2 named-tree
  # dialect: a grammar capture whose tree is a repetition of a `digit`
  # sub-rule serialized as the node list alone, dropping every unnamed
  # literal between the nodes (the dots of a version run, the " beta" of an
  # OMG version tail). The relaton-data crawlers of that era wrote the
  # emission into their published index rows, so those rows deserialize
  # carrying the raw node list — as the Ruby inspect string
  # `[{"digit" => "3"}, …]` renders (`[{digit: "3"}, {digit: "0"}, …]`) or,
  # after a JSON/YAML hop, as a real array of one-key hashes.
  #
  # Rendered verbatim such a row prints the node hashes instead of the
  # assembled number, and the print never re-parses (the relaton corpus
  # gate's Law 1a). Each affected flavor assembles the digits back into its
  # own scalar on deserialization; this module is the one definition of the
  # emission's shape.
  module LegacyTreeValue
    # One `{digit: "N"}` node, in the Ruby-inspect shorthand (`digit: "3"`)
    # or the hash-rocket spelling (`"digit" => "3"`), keys optionally quoted.
    NODE_RE = /\{\s*["']?digit["']?\s*(?::|=>)\s*["']?(\d+)["']?\s*\}/

    module_function

    # The digit values an emission carries: an Array of single-element
    # strings ("3", "0", …), or nil when +value+ is not the emission. Accepts
    # the inspect string and the real array of node hashes; any other shape
    # (a plain "3.0.0", a nil, a hash) answers nil so callers leave it alone.
    def digit_values(value)
      case value
      when ::String
        return nil unless value.match?(/\A\[#{NODE_RE.source}(?:,\s*#{NODE_RE.source})*\]\z/)

        value.scan(NODE_RE).flatten
      when ::Array
        return nil if value.empty?

        nodes = value.filter_map do |node|
          next unless node.is_a?(::Hash)

          node["digit"] || node[:digit]
        end
        return nil unless nodes.size == value.size

        nodes.map(&:to_s)
      end
    end
  end
end
