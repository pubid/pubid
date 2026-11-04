# frozen_string_literal: true

module Pubid
  module PubidUrn
    # Writes the pubid-scheme URN of an identifier hash.
    #
    #   urn:pubid:<flavor>:<node>[:<node>…][:f:<facet>…]
    #   <node> = <type>[:<core>…][:<prefix>-<value>…]
    #
    # The nodes go root first, along +base+: "ISO 9001:2015/Amd 1:2016" is
    # "is:9001:year-2015:amd:1:year-2016", so every supplement of a document
    # shares its slug prefix. A core value is positional; an absent one in
    # the middle is "~", and absent ones at the end are dropped. An optional
    # value is a prefixed atom, so it leaves no segment when it is absent.
    class Encoder
      def initialize(hash)
        @hash = hash
      end

      # @return [String] the body after "urn:pubid:"
      def body
        flavor = PubidUrn.flavor_segment(@hash["_type"])
        "#{flavor}:#{encode_identifier(@hash, flavor)}"
      end

      private

      def encode_identifier(hash, flavor)
        segments = []
        facets = []
        chain(hash).each_with_index do |node, index|
          schema = PubidUrn.type_schema!(node["_type"],
                                         error: Errors::InvalidInputError)
          node = deep_dup(node)
          node.delete("_type")
          segments << token(schema, flavor)
          segments.concat(core_segments(node, schema))
          segments.concat(atom_segments(node, schema))
          facets.concat(facet_segments(node, schema, index))
          check_placed!(node, schema)
        end
        segments.push("f", *facets) unless facets.empty?
        segments.join(":")
      end

      # The nodes from the root document to +hash+ itself.
      def chain(hash)
        nodes = []
        node = hash
        while node
          unless node.is_a?(Hash) && node["_type"].is_a?(String)
            raise Errors::InvalidInputError,
                  "a pubid URN base must be an identifier hash, " \
                  "got #{node.inspect}"
          end

          nodes.unshift(node.except("base"))
          node = node["base"]
        end
        nodes
      end

      def token(schema, flavor)
        return schema.token if schema.flavor == flavor

        "#{schema.flavor}.#{schema.token}"
      end

      def core_segments(node, schema)
        values = schema.core.map { |parts| Paths.take(node, parts) }
        values.pop while !values.empty? && values.last.nil?
        values.map do |value|
          value.nil? ? NULL : core_value(value, schema)
        end
      end

      # A core value that has the shape of structure (PubidUrn::STRUCTURE)
      # gets its first character escaped.
      def core_value(value, schema)
        unless value.is_a?(String) && !value.empty?
          raise Errors::InvalidInputError,
                "core value of #{schema.type} must be a non-empty String, " \
                "got #{value.inspect}"
        end

        encoded = Escape.encode(value)
        return encoded unless PubidUrn.structural?(encoded)

        Escape.force(value[0]) + Escape.encode(value[1..])
      end

      def atom_segments(node, schema)
        schema.atoms.filter_map do |atom|
          value = Paths.take(node, atom.parts)
          next if value.nil?

          "#{atom.prefix}-#{atom_value(value, atom, schema)}"
        end
      end

      def atom_value(value, atom, schema)
        case atom.kind
        when :int then typed(value, Integer, atom, schema).to_s
        when :id then nested(typed(value, Hash, atom, schema))
        when :ids then nested_list(typed(value, Array, atom, schema))
        else slot_value(value, atom, schema)
        end
      end

      # The value of a :string, :bool or list atom, or of a facet.
      def slot_value(value, slot, schema)
        return scalar(value, slot, schema) unless slot.list?

        typed(value, Array, slot, schema).map do |item|
          item.nil? ? NULL : scalar(item, slot, schema)
        end.join(",")
      end

      def scalar(value, slot, schema)
        if slot.element == :bool
          typed(value, [true, false], slot, schema).to_s
        else
          Escape.encode(typed(value, String, slot, schema))
        end
      end

      def nested(hash)
        "(#{Encoder.new(hash).body})"
      end

      def nested_list(hashes)
        hashes.map { |hash| nested(hash) }.join(",")
      end

      def facet_segments(node, schema, index)
        schema.facets.filter_map do |facet|
          value = Paths.take(node, facet.parts)
          next if value.nil?

          "#{index}.#{facet.name}-#{slot_value(value, facet, schema)}"
        end
      end

      def typed(value, expected, slot, schema)
        ok = if expected.is_a?(Array)
               expected.include?(value)
             else
               value.is_a?(expected)
             end
        return value if ok

        raise Errors::InvalidInputError,
              "#{schema.type} #{slot.path}: #{value.inspect} " \
              "is not #{slot.kind}"
      end

      def check_placed!(node, schema)
        left = node.reject { |_, value| Paths.blank?(value) }
        return if left.empty?

        raise Errors::InvalidInputError,
              "the pubid URN schema of #{schema.type} " \
              "does not place #{left.inspect}"
      end

      def deep_dup(value)
        case value
        when Hash then value.to_h { |k, v| [k, deep_dup(v)] }
        when Array then value.map { |v| deep_dup(v) }
        else value
        end
      end
    end
  end
end
