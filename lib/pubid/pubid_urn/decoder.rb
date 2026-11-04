# frozen_string_literal: true

module Pubid
  module PubidUrn
    # Reads the body of a pubid-scheme URN back into an identifier hash.
    # The inverse of Encoder; strict about structure. Canonical form (atom
    # order, escapes, trailing "~") is checked by PubidUrn.parse, which
    # re-encodes the result and compares.
    class Decoder
      FACET = /\A(\d+)\.([a-z0-9]+)-(.*)\z/

      def initialize(body)
        @body = body
      end

      # @return [Hash] the identifier hash (+_type+ and +base+ included)
      def to_identifier_hash
        flavor, rest = @body.split(":", 2)
        fail!("no type segment") if rest.nil? || rest.empty?
        decode_identifier(rest, flavor)
      end

      private

      def decode_identifier(body, flavor)
        tokens = PubidUrn.split_top(body, ":")
        nodes = []
        schemas = []
        i = 0
        while i < tokens.size
          token = tokens[i]
          if token == "f"
            decode_facets(tokens.drop(i + 1), nodes, schemas)
            break
          end

          schema = node_schema(token, flavor)
          node = { "_type" => schema.type }
          i = decode_core(tokens, i + 1, node, schema)
          i = decode_atoms(tokens, i, node, schema)
          nodes << node
          schemas << schema
        end
        fail!("no identifier") if nodes.empty?

        nodes.each_cons(2) { |base, node| node["base"] = base }
        nodes.last
      end

      def node_schema(token, flavor)
        if token == "type"
          fail!("type-metadata URN names a type, not a document")
        end

        schema = if PubidUrn.structural?(token)
                   owner, name = PubidUrn.split_token(token, flavor)
                   PubidUrn.flavor_schema(owner)&.for_token(name)
                 end
        fail!("unknown type or segment #{token.inspect}") unless schema

        schema
      end

      def decode_core(tokens, index, node, schema)
        schema.core.each do |parts|
          break if index >= tokens.size

          token = tokens[index]
          break if PubidUrn.structural?(token)

          Paths.put(node, parts, Escape.decode(token)) unless token == NULL
          index += 1
        end
        index
      end

      def decode_atoms(tokens, index, node, schema)
        last = -1
        while index < tokens.size &&
            (position = schema.atom_position(tokens[index]))
          if position <= last
            fail!("atom #{tokens[index].inspect} is out of order or repeated")
          end

          last = position
          atom = schema.atoms[position]
          raw = tokens[index].split("-", 2).last
          Paths.put(node, atom.parts, atom_value(raw, atom))
          index += 1
        end
        index
      end

      def atom_value(raw, atom)
        case atom.kind
        when :int then integer(raw)
        when :id then nested(raw)
        when :ids then PubidUrn.split_top(raw, ",").map { |item| nested(item) }
        else slot_value(raw, atom)
        end
      end

      # The value of a :string, :bool or list atom, or of a facet.
      def slot_value(raw, slot)
        return scalar(raw, slot) unless slot.list?

        PubidUrn.split_top(raw, ",", allow_empty: true).map do |item|
          item == NULL ? nil : scalar(item, slot)
        end
      end

      def scalar(raw, slot)
        slot.element == :bool ? boolean(raw) : Escape.decode(raw)
      end

      def boolean(raw)
        return true if raw == "true"
        return false if raw == "false"

        fail!("#{raw.inspect} is not a boolean")
      end

      def integer(raw)
        unless /\A-?[0-9]+\z/.match?(raw)
          fail!("#{raw.inspect} is not an integer")
        end

        Integer(raw, 10)
      end

      def nested(raw)
        unless raw.start_with?("(") && raw.end_with?(")")
          fail!("nested identifier #{raw.inspect} needs brackets")
        end

        Decoder.new(raw[1..-2]).to_identifier_hash
      end

      def decode_facets(tokens, nodes, schemas)
        fail!("empty facet group") if tokens.empty?

        tokens.each do |token|
          match = FACET.match(token) || fail!("bad facet #{token.inspect}")
          index = Integer(match[1], 10)
          schema = schemas[index] || fail!("facet #{token.inspect} has no node")
          facet = schema.facet(match[2]) || fail!("bad facet #{token.inspect}")
          Paths.put(nodes[index], facet.parts, slot_value(match[3], facet))
        end
      end

      def fail!(message)
        raise Errors::UrnParseError, "pubid URN #{@body.inspect}: #{message}"
      end
    end
  end
end
