# frozen_string_literal: true

module PubidNew
  # Machine-readable metadata for identifier classes
  # Provides a standardized way to describe identifier types for:
  # - Index search and lookup
  # - File naming conventions
  # - Cross-references between flavors
  # - Automated documentation generation
  module IdentifierMetadata
    class Metadata
      attr_reader :flavor, :identifier_class, :type_key, :title, :short, :abbr,
                  :base_class, :supplement_class, :stage_codes, :machine_codes

      def initialize(flavor:, identifier_class:, type_key:, title:, short: nil,
                     abbr: [], base_class: nil, supplement_class: nil,
                     stage_codes: [], machine_codes: {}, **extra_metadata)
        @flavor = flavor
        @identifier_class = identifier_class
        @type_key = type_key
        @title = title
        @short = short
        @abbr = Array(abbr)
        @base_class = base_class
        @supplement_class = supplement_class
        @stage_codes = Array(stage_codes)
        @machine_codes = machine_codes
        @extra_metadata = extra_metadata
      end

      # Fully qualified class name
      def qualified_class_name
        "#{flavor.capitalize}::#{identifier_class}"
      end

      # Machine-readable slug for file naming
      def slug
        "#{flavor}-#{type_key}".downcase.gsub(/[^a-z0-9]+/, "-")
      end

      # URN-style identifier for this type
      def urn
        "urn:pubid:#{flavor}:type:#{type_key}"
      end

      # Check if this identifier type matches a code
      def matches_code?(code)
        return false if code.nil?

        code_str = code.to_s.downcase.strip
        @abbr.map(&:to_s).map(&:downcase).include?(code_str) ||
          @type_key.to_s.downcase == code_str
      end

      # Additional metadata accessors
      def [](key)
        @extra_metadata[key]
      end

      def to_h
        {
          flavor: @flavor,
          identifier_class: @identifier_class,
          type_key: @type_key,
          title: @title,
          short: @short,
          abbr: @abbr,
          base_class: @base_class,
          supplement_class: @supplement_class,
          stage_codes: @stage_codes,
          machine_codes: @machine_codes,
          slug: slug,
          urn: urn,
          qualified_class_name: qualified_class_name,
        }.merge(@extra_metadata)
      end

      def to_json(*args)
        to_h.to_json(*args)
      end
    end

    module ClassMethods
      # Define metadata for an identifier class
      # @param attrs [Hash] Metadata attributes
      def define_metadata(**attrs)
        flavor = attrs.fetch(:flavor) do
          # Extract flavor from class name (e.g., "PubidNew::Iso::Identifiers::Foo" -> "iso")
          name.to_s.split("::")[1..2]&.join("/")&.downcase || "unknown"
        end

        # Extract class name (e.g., "PubidNew::Iso::Identifiers::Foo" -> "Foo")
        identifier_class = name.to_s.split("::")&.last

        @metadata = Metadata.new(
          flavor: flavor,
          identifier_class: identifier_class,
          **attrs
        )
      end

      # Get the metadata for this class
      # @return [Metadata, nil]
      def metadata
        @metadata ||= if superclass.respond_to?(:metadata)
                        superclass.metadata
                      else
                        nil
                      end
      end

      # Get the type key from metadata
      # @return [Symbol, nil]
      def type_key
        metadata&.type_key
      end

      # Get the title from metadata
      # @return [String, nil]
      def type_title
        metadata&.title
      end
    end

    module InstanceMethods
      # Get metadata for this instance's class
      # @return [Metadata, nil]
      def metadata
        self.class.metadata
      end

      # Get the type key for this identifier
      # @return [Symbol, nil]
      def type_key
        self.class.type_key
      end

      # Get the machine-readable slug
      # @return [String, nil]
      def slug
        metadata&.slug
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
      base.include(InstanceMethods)
    end
  end
end
