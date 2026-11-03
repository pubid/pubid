# frozen_string_literal: true

module Pubid
  module PubidUrn
    # Reads and writes a dotted key path ("edition.number",
    # "languages.*.code") in an identifier hash.
    #
    # +take+ removes what it reads, so after every core path, atom and facet
    # has been taken, anything left in the node is a key that the schema
    # does not place — the encoder refuses it rather than drop it silently.
    #
    # A degenerate component may serialize as a bare scalar ("edition" =>
    # "2" rather than {"number" => "2"}, see FLAT_SCALAR_FIELDS). Where a
    # path expects a Hash and finds a scalar, the scalar IS the value of
    # the path. +put+ always writes the nested form, which +from_hash+ reads
    # as well, so the rebuilt identifier serializes alike.
    module Paths
      module_function

      # @return [Object, nil] the value, or nil when the path is absent
      def take(container, parts)
        return nil unless container.is_a?(Hash) && container.key?(parts.first)

        key, *rest = parts
        return container.delete(key) if rest.empty?

        value = container[key]
        if rest.first == "*"
          take_elements(container, key, value, rest.drop(1))
        elsif value.is_a?(Hash)
          take(value, rest)
        elsif rest.size == 1
          container.delete(key)
        end
      end

      def take_elements(container, key, value, rest)
        return nil unless value.is_a?(Array)
        return container.delete(key) if rest.empty?

        values = value.each_with_index.map do |element, i|
          if element.is_a?(Hash)
            take(element, rest)
          elsif rest.size == 1 && !element.nil?
            value[i] = {}
            element
          end
        end
        values.all?(&:nil?) ? nil : values
      end

      # Write +value+ (nil writes nothing).
      def put(container, parts, value)
        return if value.nil?

        key, *rest = parts
        if rest.empty?
          container[key] = value
        elsif rest.first == "*"
          put_elements(container, key, value, rest.drop(1))
        else
          put(container[key] ||= {}, rest, value)
        end
      end

      def put_elements(container, key, values, rest)
        return container[key] = values if rest.empty?

        elements = (container[key] ||= [])
        values.each_with_index do |value, i|
          next if value.nil?

          put(elements[i] ||= {}, rest, value)
        end
      end

      # True when nothing but empty containers is left.
      def blank?(value)
        case value
        when Hash then value.each_value.all? { |v| blank?(v) }
        when Array then value.all? { |v| blank?(v) }
        else false
        end
      end
    end
  end
end
