# frozen_string_literal: true

require "set"

module Pubid
  module Export
    # Abstract base class for per-flavor metadata extraction.
    # Subclasses implement strategy for different Scheme patterns.
    #
    # Open/Closed: New flavors add a subclass; no existing code changes.
    # Single Responsibility: Each subclass extracts data for one Scheme pattern.
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
          when "cen_cenelec" then Pubid::CenCenelec
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
        scheme_klasses = []

        # Pattern 1: Class methods (ISO, IEC, ASTM, etc.)
        if scheme&.respond_to?(:identifiers)
          scheme_klasses = scheme.identifiers
        end

        # Pattern 2: Instance-based (AMCA, BSI)
        if scheme_klasses.empty? && scheme
          instance = scheme.respond_to?(:new) ? scheme.new : nil
          if instance && instance.identifiers && !instance.identifiers.empty?
            scheme_klasses = instance.identifiers
          end
        end

        # Build set of website keys from Scheme classes to avoid duplicates
        known_website_keys = Set.new
        scheme_klasses.each do |klass|
          info = extract_type_info(klass)
          known_website_keys << info[:key].to_s if info[:key]
        end

        # Supplement with any typed classes in the Identifiers module
        # that weren't returned by Scheme (e.g., supplements, fragments)
        additional = discover_additional_typed_classes(scheme_klasses, known_website_keys)
        scheme_klasses + additional
      end

      # Classes to skip when discovering additional identifier types
      SKIP_CLASSES = %w[Base].freeze

      def discover_additional_typed_classes(known_classes, known_website_keys = Set.new)
        mod = scheme_module
        return [] unless mod

        idents_mod = mod.const_get(:Identifiers)
        known_set = Set.new(known_classes)

        idents_mod.constants.filter_map do |c|
          klass = idents_mod.const_get(c)
        rescue NameError
          next
        else
          next unless klass.is_a?(Class)
          next if known_set.include?(klass)
          next if klass <= Exception
          next if SKIP_CLASSES.include?(klass.name&.split("::")&.last)

          # Check if this class produces a duplicate website key
          info = extract_type_info(klass)
          wkey = info[:key]&.to_s
          next if wkey && known_website_keys.include?(wkey)

          known_website_keys << wkey if wkey
          klass
        end
      end

      # Explicit overrides mapping (flavor, library_key) → website key
      # for cases where derived key doesn't match the website convention.
      WEBSITE_KEY_OVERRIDES = {
        # ISO
        [%i[iso], :is] => :international_standard,
        [%i[iso], :tr] => :technical_report,
        [%i[iso], :ts] => :technical_specification,
        [%i[iso], :pas] => :publicly_available_specification,
        [%i[iso], :tta] => :technology_trends_assessments,
        [%i[iso], :iwa] => :international_workshop_agreement,
        [%i[iso], :isp] => :international_standardized_profile,
        [%i[iso], :rec] => :recommendation,
        [%i[iso], :dir] => :directives,
        [%i[iso], :"dir-sup"] => :directives_supplement,
        [%i[iso], :amd] => :amendment,
        [%i[iso], :cor] => :corrigendum,
        [%i[iso], :suppl] => :supplement,
        [%i[iso], :ext] => :extract,
        [%i[iso], :add] => :addendum,
        [%i[iso], :tc] => :tc_document,
        # IEC
        [%i[iec], :is] => :international_standard,
        [%i[iec], :tr] => :technical_report,
        [%i[iec], :ts] => :technical_specification,
        [%i[iec], :pas] => :publicly_available_specification,
        [%i[iec], :trf] => :test_report_form,
        [%i[iec], :ish] => :interpretation_sheet,
        [%i[iec], :srd] => :systems_reference_document,
        [%i[iec], :wd] => :working_document,
        [%i[iec], :frag] => :fragment_identifier,
        [%i[iec], :amd] => :amendment,
        [%i[iec], :cor] => :corrigendum,
        [%i[iec], :cs] => :component_specification,
        [%i[iec], :od] => :operational_document,
        [%i[iec], :sttr] => :societal_technology_trend_report,
        [%i[iec], :wp] => :white_paper,
        # IEEE
        [%i[ieee], :std] => :standard,
        # NIST
        [%i[nist], :sp] => :special_publication,
        [%i[nist], :fips] => :federal_information_processing_standards,
        [%i[nist], :ir] => :interagency_report,
        [%i[nist], :hb] => :handbook,
        [%i[nist], :tn] => :technical_note,
        [%i[nist], :circ] => :circular,
        [%i[nist], :circ_supp] => :circular_supplement,
        [%i[nist], :crpl] => :crpl_report,
        [%i[nist], :rpt] => :report,
        [%i[nist], :mono] => :monograph,
        [%i[nist], :mp] => :miscellaneous_publication,
        [%i[nist], :gcr] => :grant_contractor_report,
        [%i[nist], :lc] => :letter_circular,
        [%i[nist], :cs] => :commercial_standard,
        [%i[nist], :cse] => :commercial_standard_emergency,
        [%i[nist], :csm] => :commercial_standards_monthly,
        # BSI — adopted types share keys with base types, need unique mappings
        [%i[bsi], :bs] => :british_standard,
        [%i[bsi], :pd] => :published_document,
        [%i[bsi], :pas] => :publicly_available_specification,
        [%i[bsi], :na] => :national_annex,
        [%i[bsi], :dd] => :draft_document,
        [%i[bsi], :ep] => :electronic_book,
        [%i[bsi], :ts] => :technical_specification,
        [%i[bsi], :handbook] => :handbook,
        [%i[bsi], :aerospace] => :aerospace_standard,
        # CEN-CENELEC
        [%i[cen_cenelec], :en] => :european_norm,
        [%i[cen_cenelec], :ts] => :technical_specification,
        [%i[cen_cenelec], :tr] => :technical_report,
        [%i[cen_cenelec], :cwa] => :cen_workshop_agreement,
        [%i[cen_cenelec], :hd] => :harmonization_document,
        [%i[cen_cenelec], :es] => :european_specification,
        [%i[cen_cenelec], :cr] => :cen_report,
        [%i[cen_cenelec], :env] => :european_prestandard,
        # IDF
        [%i[idf], :is] => :international_standard,
        [%i[idf], :rm] => :reviewed_method,
        [%i[idf], :amd] => :amendment,
        [%i[idf], :cor] => :corrigendum,
        # CCSDS
        [%i[ccsds], :base] => :base,
        [%i[ccsds], :cor] => :corrigendum,
        # JIS
        [%i[jis], :jis] => :japanese_industrial_standard,
        [%i[jis], :tr] => :technical_report,
        [%i[jis], :ts] => :technical_specification,
        # SAE
        [%i[sae], :base] => :standard,
        # ANSI
        [%i[ansi], :ans] => :american_national_standard,
      }.freeze

      # Per-class overrides keyed by class name (for classes that share type keys)
      CLASS_KEY_OVERRIDES = {
        "Pubid::Bsi::Identifiers::AdoptedEuropeanNorm" => "adopted_european_norm",
        "Pubid::Bsi::Identifiers::AdoptedInternationalStandard" => "adopted_international_standard",
        "Pubid::CenCenelec::Identifiers::AdoptedEuropeanNorm" => "adopted_european_norm",
        "Pubid::Ansi::Identifiers::Standard" => "standard",
        "Pubid::Ansi::Identifiers::AmericanNationalStandard" => "american_national_standard",
        "Pubid::Jis::Identifiers::Standard" => "standard",
        "Pubid::Ieee::Identifiers::Nesc::Standard" => "nesc",
        "Pubid::Ieee::Identifiers::Nesc::Draft" => "nesc",
        "Pubid::Ieee::Identifiers::Nesc::Handbook" => "nesc",
        "Pubid::Ieee::Identifiers::Nesc::Redline" => "nesc",
      }.freeze

      def extract_type_info(klass)
        # Per-class override takes highest priority
        class_key = CLASS_KEY_OVERRIDES[klass.name]
        if class_key
          type_info = begin
            klass.respond_to?(:type) ? klass.type : nil
          rescue NotImplementedError
            nil
          end
          metadata = klass.respond_to?(:metadata) ? klass.metadata : nil
          return {
            key: class_key,
            title: type_info&.dig(:title) || metadata&.title || class_key.tr("_", " ").capitalize,
            short: type_info&.dig(:short) || metadata&.short,
            abbr: metadata&.abbr || [],
          }
        end

        type_info = begin
          klass.respond_to?(:type) ? klass.type : nil
        rescue NotImplementedError
          nil
        end
        metadata = klass.respond_to?(:metadata) ? klass.metadata : nil

        lib_key = type_info&.dig(:key)
        title = type_info&.dig(:title) || metadata&.title
        short = type_info&.dig(:short) || metadata&.short
        abbr = metadata&.abbr || []

        # Derive from class name when def self.type is missing
        unless lib_key
          class_name = klass.name&.split("::")&.last
          lib_key = class_name&.gsub(/([A-Z])/, '_\1')&.downcase&.sub(/^_/, "")&.to_sym
          title ||= class_name&.gsub(/([A-Z])/, ' \1')&.strip
        end

        # Map library key to website-compatible key
        website_key = resolve_website_key(lib_key)

        {
          key: website_key,
          title: title,
          short: short,
          abbr: abbr,
        }
      end

      def resolve_website_key(lib_key)
        key_str = lib_key.to_s
        WEBSITE_KEY_OVERRIDES.each do |(flavors, from_key), to_key|
          next unless flavors.include?(flavor)
          return to_key.to_s if from_key.to_s == key_str
        end
        key_str
      end

      def extract_typed_stages(klass)
        return [] unless klass.const_defined?(:TYPED_STAGES)

        klass.const_get(:TYPED_STAGES)
      rescue NameError
        []
      end

      # Map flavor keys to fixture directory names when they differ
      FIXTURE_DIR_ALIASES = {
      }.freeze

      def fixture_examples
        # __dir__ = lib/pubid/export → go up 3 levels to gem root, then spec/fixtures
        gem_root = File.expand_path("../../..", __dir__)
        dir_name = FIXTURE_DIR_ALIASES[flavor] || flavor.to_s
        base = File.join(gem_root, "spec", "fixtures", dir_name, "identifiers", "pass")
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

      def extract_wrapper_types
        names = WRAPPER_CLASSES[flavor]
        return [] unless names

        mod = scheme_module
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
    end
  end
end
