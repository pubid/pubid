# frozen_string_literal: true

require "set"

module Pubid
  module Export
    # Unified metadata extractor for all flavors.
    #
    # Uses the self-describing type interface (identifier_types, all_typed_stages,
    # locate_type, locate_stage) on each flavor module. No Scheme dependency (Scheme class removed).
    #
    # Open/Closed: Adding a new flavor requires only adding it to Exporter::FLAVORS.
    # Single Responsibility: Extracts metadata from flavor modules into value objects.
    # Single Source of Truth: Each identifier class IS the type definition.
    class FlavorExporter
      attr_reader :flavor

      # Wrapper classes to discover per flavor (overlay patterns that wrap base identifiers)
      WRAPPER_CLASSES = {
        iec: %i[VapIdentifier],
        bsi: %i[ValueAddedPublication],
      }.freeze

      def initialize(flavor)
        @flavor = flavor
      end

      def export
        mod = flavor_module
        return nil unless mod

        klasses = resolve_identifier_classes(mod)
        return nil if klasses.empty?

        fixture_data = fixture_examples
        seen_keys = Set.new

        identifier_types = klasses.filter_map do |klass|
          info = extract_type_info(klass)
          next if seen_keys.include?(info[:key])

          seen_keys << info[:key]

          stages = extract_typed_stages(klass)
          examples = match_examples(fixture_data, info[:key]&.to_s, klass)

          IdentifierTypeResult.new(
            key: info[:key],
            title: info[:title],
            short: info[:short],
            abbr: info[:abbr],
            typed_stages: stages,
            examples: examples,
          )
        end

        FlavorResult.new(
          flavor: flavor,
          identifier_types: identifier_types,
          wrapper_types: extract_wrapper_types,
          attributes: extract_attributes(klasses.first),
        )
      end

      protected

      # Resolve identifier classes from the flavor module.
      # Primary: use the module's self-describing identifier_types method.
      # Fallback: scan the Identifiers namespace directly for Pubid::Identifier
      # subclasses (handles ETSI, ITU, and other non-standard patterns).
      def resolve_identifier_classes(mod)
        klasses = mod.identifier_types
        return klasses if klasses && !klasses.empty?

        discover_from_namespace(mod)
      end

      # Scan Identifiers namespace for all Pubid::Identifier subclasses,
      # excluding structural base classes.
      def discover_from_namespace(mod)
        return [] unless mod.const_defined?(:Identifiers)

        idents_mod = mod.const_get(:Identifiers)
        collect_identifier_classes(idents_mod)
      end

      # Recursively collect all Pubid::Identifier subclasses from a module,
      # descending into submodules (e.g., IEEE's Nesc namespace).
      def collect_identifier_classes(mod)
        result = []
        mod.constants.each do |c|
          const = begin; mod.const_get(c); rescue NameError; next; end
          if const.is_a?(Module) && !const.is_a?(Class)
            result.concat(collect_identifier_classes(const))
          elsif const.is_a?(Class) && const < Pubid::Identifier
            result << const
          end
        end
        result
      end

      # Map flavor symbol to the flavor module.
      def flavor_module
        @flavor_module ||= begin
          mod_name = flavor.to_s.gsub(/(?:^|_)(.)/) { $1.upcase }
          Pubid.const_get(mod_name)
        rescue NameError
          nil
        end
      end

      def extract_type_info(klass)
        type_info = safe_type(klass)
        metadata = safe_metadata(klass)

        key = type_info&.dig(:web) || type_info&.dig(:key)
        title = type_info&.dig(:title) || metadata&.title
        short = type_info&.dig(:short) || metadata&.short
        abbr = metadata&.abbr || []

        unless key
          class_name = klass.name&.split("::")&.last
          key = class_name&.gsub(/([A-Z])/, '_\1')&.downcase&.sub(/^_/, "")
          title ||= class_name&.gsub(/([A-Z])/, ' \1')&.strip
        end

        { key: key&.to_s, title: title, short: short, abbr: abbr }
      end

      def extract_typed_stages(klass)
        return [] unless klass.const_defined?(:TYPED_STAGES)

        klass.const_get(:TYPED_STAGES)
      rescue NameError
        []
      end

      # Fixture example extraction
      def fixture_examples
        gem_root = File.expand_path("../../..", __dir__)
        base = File.join(gem_root, "spec", "fixtures", flavor.to_s, "identifiers",
                         "pass")
        return {} unless Dir.exist?(base)

        examples = {}
        Dir.glob(File.join(base, "*.txt")).each do |path|
          type_key = File.basename(path, ".txt")
          identifiers = parse_fixture_file(path)
          examples[type_key] = identifiers if identifiers.any?
        end
        examples
      end

      def parse_fixture_file(path)
        identifiers = []
        File.readlines(path, chomp: true).each do |line|
          next if line.start_with?("#") || line.strip.empty?

          if line.start_with?("!")
            parts = line.split("!")
            input = parts[2]&.strip
            identifiers << input if input && !input.empty?
          else
            identifiers << line.strip
          end
        end
        identifiers.uniq.first(10)
      end

      def match_examples(fixture_data, type_key, klass)
        return [] unless type_key

        # Try direct type key match first
        examples = fixture_data[type_key] ||
          fixture_data[type_key.gsub("_", "")] ||
          []

        return examples if examples.any?

        # Try class name match
        class_name = klass.name&.split("::")&.last
        snake_name = class_name&.gsub(/([A-Z])/, '_\1')&.downcase&.sub(/^_/, "")
        if snake_name && fixture_data.key?(snake_name)
          fixture_data[snake_name]
        else
          []
        end
      end

      def extract_attributes(klass)
        klass.model_attributes.keys.map(&:to_s)
      rescue NoMethodError
        []
      end

      def extract_wrapper_types
        names = WRAPPER_CLASSES[flavor]
        return [] unless names

        mod = flavor_module
        return [] unless mod

        identifiers_mod = mod.const_get(:Identifiers)
        names.filter_map do |name|
          klass = identifiers_mod.const_get(name)
          info = extract_type_info(klass)
          IdentifierTypeResult.new(
            key: info[:key],
            title: info[:title],
            short: info[:short],
            abbr: info[:abbr],
            typed_stages: [],
            examples: [],
          )
        rescue NameError
          nil
        end
      end

      private

      def safe_type(klass)
        klass.type
      rescue NoMethodError, NotImplementedError
        nil
      end

      def safe_metadata(klass)
        klass.metadata
      rescue NoMethodError
        nil
      end
    end
  end
end
