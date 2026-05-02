# frozen_string_literal: true

module Pubid
  module Export
    # Abstract base class for per-flavor metadata extraction.
    # Subclasses implement strategy for different Scheme patterns.
    #
    # Open/Closed: New flavors add a subclass; no existing code changes.
    # Single Responsibility: Each subclass extracts data for one Scheme pattern.
    class FlavorExporter
      attr_reader :flavor

      def initialize(flavor)
        @flavor = flavor
      end

      # Subclasses must override
      def export
        raise NotImplementedError
      end

      protected

      def scheme_module
        @scheme_module ||= begin
          # const_get doesn't trigger autoload; reference the constant directly
          case flavor.to_s
          when "iso" then Pubid::Iso
          when "iec" then Pubid::Iec
          when "ieee" then Pubid::Ieee
          when "nist" then Pubid::Nist
          when "bsi" then Pubid::Bsi
          when "itu" then Pubid::Itu
          when "cen" then Pubid::Cen
          when "etsi" then Pubid::Etsi
          when "ansi" then Pubid::Ansi
          when "astm" then Pubid::Astm
          when "ashrae" then Pubid::Ashrae
          when "asme" then Pubid::Asme
          when "ccsds" then Pubid::Ccsds
          when "cie" then Pubid::Cie
          when "csa" then Pubid::Csa
          when "jis" then Pubid::Jis
          when "jcgm" then Pubid::Jcgm
          when "oiml" then Pubid::Oiml
          when "idf" then Pubid::Idf
          when "api" then Pubid::Api
          when "amca" then Pubid::Amca
          when "plateau" then Pubid::Plateau
          when "sae" then Pubid::Sae
          end
        end
      end

      def scheme_class
        @scheme_class ||= begin
          mod = scheme_module
          mod&.const_get(:Scheme)
        rescue NameError
          nil
        end
      end

      def identifier_classes
        resolve_identifier_classes
      end

      def resolve_identifier_classes
        scheme = scheme_class
        return [] unless scheme

        # Pattern 1: Class methods (ISO, IEC, ASTM, etc.)
        if scheme.respond_to?(:identifiers)
          return scheme.identifiers
        end

        # Pattern 2: Instance-based (AMCA, BSI)
        instance = scheme.respond_to?(:new) ? scheme.new : nil
        if instance && instance.identifiers && !instance.identifiers.empty?
          return instance.identifiers
        end

        []
      end

      def extract_type_info(klass)
        type_info = klass.respond_to?(:type) ? klass.type : nil
        metadata = klass.respond_to?(:metadata) ? klass.metadata : nil

        key = type_info&.dig(:key)
        title = type_info&.dig(:title) || metadata&.title
        short = type_info&.dig(:short) || metadata&.short
        abbr = metadata&.abbr || []

        # Fallback: derive from class name when def self.type is missing
        unless key
          class_name = klass.name&.split("::")&.last
          key = class_name&.gsub(/([A-Z])/, '_\1')&.downcase&.sub(/^_/, "")&.to_sym
          title ||= class_name&.gsub(/([A-Z])/, ' \1')&.strip
        end

        {
          key: key,
          title: title,
          short: short,
          abbr: abbr,
        }
      end

      def extract_typed_stages(klass)
        return [] unless klass.const_defined?(:TYPED_STAGES)

        klass.const_get(:TYPED_STAGES)
      rescue NameError
        []
      end

      def fixture_examples
        # __dir__ = lib/pubid/export → go up 3 levels to gem root, then spec/fixtures
        gem_root = File.expand_path("../../..", __dir__)
        base = File.join(gem_root, "spec", "fixtures", flavor.to_s, "identifiers", "pass")
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

          # Format: "!Type input!expected" or just "input"
          if line.start_with?("!")
            parts = line.split("!")
            # ["", "Type", "input", "expected"] or ["", "Type", "input"]
            input = parts[2]&.strip
            identifiers << input if input && !input.empty?
          else
            identifiers << line.strip
          end
        end
        identifiers.uniq.first(10)
      end

      def map_fixture_key_to_type_key(fixture_key)
        fixture_key
      end

      def extract_attributes(klass)
        return [] unless klass.respond_to?(:model_attributes)

        klass.model_attributes.keys.map(&:to_s)
      rescue NoMethodError
        []
      end
    end
  end
end
