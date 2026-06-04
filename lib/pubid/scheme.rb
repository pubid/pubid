# frozen_string_literal: true

module Pubid
  # Base Scheme class defining the standard interface for all flavor schemes.
  #
  # The Scheme acts as a registry for identifier types and their associated
  # typed stages. Each flavor (ISO, IEC, IEEE, etc.) should have a Scheme that
  # implements this interface.
  #
  # == Standard Interface
  #
  # All Scheme implementations must provide these methods:
  #
  # - locate_typed_stage_by_abbr(abbr) -> Find a TypedStage by abbreviation
  # - locate_identifier_klass_by_type_code(type_code) -> Find an identifier class
  # - typed_stages -> Get all typed stages for base identifiers
  # - supplement_typed_stages -> Get typed stages for supplements
  # - all_typed_stages -> Get all typed stages combined
  # - identifiers -> Get all base identifier classes
  # - supplement_identifiers -> Get all supplement identifier classes
  # - all_identifier_classes -> Get all identifier classes combined
  #
  # == Implementation Patterns
  #
  # There are several valid patterns for implementing a Scheme:
  #
  # 1. Class-based (ISO, IEEE, JCGM, JIS, CCSDS, ASHRAE):
  #    Use class << self with class methods
  #
  # 2. Instance-based with constants (BSI, CEN):
  #    Use TYPED_STAGES_REGISTRY and instance methods
  #
  # 3. Transform-based (ITU):
  #    Use model_class and transform methods (no typed stages)
  #
  # 4. Data class (ETSI, Plateau):
  #    Use Lutaml::Model::Serializable as a data model
  #
  # 5. Inheritance-based (AMCA):
  #    Inherit from Pubid::Scheme base class
  #
  # == Performance
  #
  # All registry lookups are memoized for performance. Callers can rely on
  # repeated calls being O(1) after the first call.
  #
  class Scheme
    # Registry of identifiers for this scheme
    attr_accessor :identifiers,
                  :stages,
                  :types,
                  :languages,
                  :publishers,
                  :supplement_identifiers

    def initialize(
      identifiers: [], stages: [], types: [], languages: [], publishers: [],
      supplement_identifiers: []
    )
      @identifiers = identifiers
      @supplement_identifiers = supplement_identifiers
      @stages = stages
      @types = types
      @languages = languages
      @publishers = publishers
    end

    def configure
      yield self if block_given?
    end

    # Get all typed stages for base identifiers
    # @return [Array<TypedStage>] All typed stages from identifiers
    # @note Memoized for performance
    def typed_stages
      return @typed_stages if defined?(@typed_stages)

      @typed_stages = @identifiers.filter_map do |identifier_class|
        identifier_class.const_defined?(:TYPED_STAGES) ? identifier_class.const_get(:TYPED_STAGES) : nil
      end.flatten
    end

    # Get all typed stages for supplement identifiers
    # @return [Array<TypedStage>] All typed stages from supplement identifiers
    # @note Memoized for performance
    def supplement_typed_stages
      return @supplement_typed_stages if defined?(@supplement_typed_stages)

      @supplement_typed_stages = @supplement_identifiers.filter_map do |identifier_class|
        identifier_class.const_defined?(:TYPED_STAGES) ? identifier_class.const_get(:TYPED_STAGES) : nil
      end.flatten
    end

    # Get all typed stages (base + supplements), sorted by abbreviation
    # @return [Array<TypedStage>] All typed stages sorted by abbreviation
    # @note Memoized for performance
    def all_typed_stages
      return @all_typed_stages if defined?(@all_typed_stages)

      @all_typed_stages = (typed_stages + supplement_typed_stages).sort_by do |ts|
        (ts.abbr.first || "").to_s
      end.reverse
    end

    # Locate a TypedStage by abbreviation
    # @param abbr [String, Symbol] The abbreviation to find
    # @return [TypedStage, nil] The matching TypedStage, or nil if not found
    # @note Uses hash-based index for O(1) lookup, falls back to linear search
    def locate_typed_stage_by_abbr(abbr)
      abbr = "" if abbr.nil? || abbr.to_s.strip.empty?

      # Try hash-based index first (O(1))
      typed_stage = typed_stage_index[abbr]

      # Fall back to linear search if not found (for abbreviations with
      # special formatting or edge cases)
      typed_stage || all_typed_stages.detect do |ts|
        ts.abbr.include?(abbr)
      end
    end

    # Locate a TypedStage by stage code
    # @param stage_code [String, Symbol] The stage code to find
    # @return [TypedStage, nil] The matching TypedStage, or nil if not found
    # @note Uses linear search for stage code lookup
    def locate_typed_stage_by_stage_code(stage_code)
      stage_code_sym = stage_code.to_sym

      all_typed_stages.detect do |ts|
        ts.stage_code.to_sym == stage_code_sym
      end
    end

    # Locate a TypedStage by its unique per-typed-stage code
    # @param code [String, Symbol] The code to find (e.g. :dtr, :fdisp)
    # @return [TypedStage, nil] The matching TypedStage, or nil if not found
    # @note Uses linear search for code lookup
    def locate_typed_stage_by_code(code)
      code_sym = code.to_sym

      all_typed_stages.detect do |ts|
        ts.code&.to_sym == code_sym
      end
    end

    # Locate a TypedStage by harmonized stage code
    # @param harmonized_code [String] The harmonized stage code to find (e.g., "00.00", "10.00")
    # @return [TypedStage, nil] The matching TypedStage, or nil if not found
    # @note Uses linear search to check harmonized_stages arrays
    def locate_typed_stage_by_harmonized_code(harmonized_code)
      harmonized_str = harmonized_code.to_s

      all_typed_stages.detect do |ts|
        ts.harmonized_stages&.include?(harmonized_str)
      end
    end

    # Hash-based index of typed stages by abbreviation
    # @return [Hash<String, TypedStage>] index mapping abbreviations to typed stages
    # @note Memoized for O(1) lookup performance
    def typed_stage_index
      @typed_stage_index ||= build_typed_stage_index
    end

    # Get all identifier classes sorted by type key
    # @return [Array<Class>] All identifier classes sorted by type key
    # @note Memoized for performance
    def all_identifier_classes
      return @all_identifier_classes if defined?(@all_identifier_classes)

      @all_identifier_classes = (@identifiers + @supplement_identifiers).sort_by do |klass|
        (klass.type&.dig(:key) || "").to_s
      end
    end
    alias all_identifier_classes_by_type_code all_identifier_classes

    # Locate an identifier class by type code
    # @param type_code [String, Symbol] The type code to find
    # @return [Class, nil] The matching identifier class, or nil if not found
    # @note Uses hash-based index for O(1) lookup, falls back to linear search
    def locate_identifier_klass_by_type_code(type_code)
      type_str = type_code.to_s

      # Try hash-based index first (O(1))
      identifier_klass = identifier_class_index[type_str]

      # Fall back to linear search if not found
      identifier_klass || all_identifier_classes.detect do |identifier_class|
        identifier_class.type&.dig(:key)&.to_s == type_str
      end
    end

    # Hash-based index of identifier classes by type code
    # @return [Hash<String, Class>] index mapping type codes to identifier classes
    # @note Memoized for O(1) lookup performance
    def identifier_class_index
      @identifier_class_index ||= build_identifier_class_index
    end

    protected

    # Build hash-based index of typed stages by abbreviation
    # @return [Hash<String, TypedStage>] index mapping abbreviations to typed stages
    def build_typed_stage_index
      all_typed_stages.each_with_object({}) do |ts, index|
        ts.abbr.each { |abbr| index[abbr] = ts }
      end
    end

    # Build hash-based index of identifier classes by type code
    # @return [Hash<String, Class>] index mapping type codes to identifier classes
    def build_identifier_class_index
      all_identifier_classes.each_with_object({}) do |klass, index|
        type_key = klass.type&.dig(:key)&.to_s
        index[type_key] = klass if type_key
      end
    end
  end
end
