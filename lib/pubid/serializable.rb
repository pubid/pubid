# frozen_string_literal: true

require_relative "serializable/deserializer"
require "json"
require "yaml"

module Pubid
  # Serializable module provides two-way machine-readable conversion for identifiers.
  #
  # This module enables identifiers to be converted to and from structured formats
  # (hash, JSON, XML) and machine-readable string formats.
  #
  # @example Export to hash
  #   id = Pubid::Iso.parse("ISO 9001:2015")
  #   id.to_h # => {flavor: "iso", publisher: "ISO", number: "9001", year: "2015", ...}
  #
  # @example Export to JSON
  #   id = Pubid::Iso.parse("ISO 9001:2015")
  #   id.to_json # => '{"flavor":"iso","publisher":"ISO",...}'
  #
  # @example Import from hash
  #   hash = {flavor: "iso", publisher: "ISO", number: "9001", year: "2015"}
  #   Pubid::Serializable.from_h(hash) # => #<Pubid::Iso::Identifiers::InternationalStandard>
  #
  # @example Import from JSON
  #   json = '{"flavor":"iso","publisher":"ISO","number":"9001","year":"2015"}'
  #   Pubid::Serializable.from_json(json) # => #<Pubid::Iso::Identifiers::InternationalStandard>
  #
  module Serializable
    autoload :Deserializer, "pubid/serializable/deserializer"

    # Convert identifier to structured hash
    #
    # @param include_metadata [Boolean] whether to include URN and other metadata
    # @return [Hash] structured representation of the identifier
    def to_h(include_metadata: true)
      hash = base_hash
      hash.merge!(supplements_hash) if has_supplements?
      hash.merge!(metadata_hash) if include_metadata

      hash.compact
    end

    # Convert identifier to JSON string
    #
    # @param args [Array] arguments passed to JSON.generate
    # @return [String] JSON representation of the identifier
    def to_json(*args)
      to_h.to_json(*args)
    end

    # Convert identifier to YAML string
    #
    # @param args [Array] arguments passed to YAML.dump
    # @return [String] YAML representation of the identifier
    def to_yaml(*args)
      to_h.to_yaml(*args)
    end

    # Convert identifier to machine-readable string format
    #
    # Uses dot-separated format similar to NIST's machine-readable format.
    # Format: PUBLISHER[.TYPE].NUMBER[-PART].YEAR
    #
    # @return [String] machine-readable identifier string
    def to_mr_string
      parts = []

      parts << mr_publisher
      # Only include type if it's not IS (default)
      parts << mr_type if mr_type && mr_type != "is" && !mr_type.empty?

      # Number with optional part (use dash separator for part)
      number_part = mr_number
      number_part = "#{mr_number}-#{mr_part}" if mr_part && mr_number
      parts << number_part if number_part

      parts << mr_year if mr_year

      parts.compact.join(".")
    end

    # Create identifier from structured hash
    #
    # @param hash [Hash] structured identifier data
    # @return [Identifier] parsed identifier instance
    # @raise [ArgumentError] if flavor is missing or invalid
    def self.from_h(hash)
      Deserializer.from_h(hash)
    end

    # Create identifier from JSON string
    #
    # @param json_string [String] JSON representation of identifier
    # @return [Identifier] parsed identifier instance
    def self.from_json(json_string)
      from_h(JSON.parse(json_string))
    end

    # Create identifier from YAML string
    #
    # @param yaml_string [String] YAML representation of identifier
    # @return [Identifier] parsed identifier instance
    def self.from_yaml(yaml_string)
      from_h(YAML.safe_load(yaml_string, permitted_classes: [Symbol],
                                         aliases: true))
    end

    # Create identifier from machine-readable string
    #
    # @param mr_string [String] dot-separated machine-readable identifier
    # @return [Identifier] parsed identifier instance
    def self.from_mr_string(mr_string)
      # Detect flavor from publisher prefix
      flavor = detect_flavor_from_mr(mr_string)

      # Get the appropriate flavor module
      flavor_module = Pubid.const_get(flavor.capitalize)

      # Convert MR string to parseable format
      # "ISO.9001.2015" → "ISO 9001:2015"
      # "ISO.8601-1.2019" → "ISO 8601-1:2019"
      # "ISO.4" → "ISO 4" (undated)
      parts = mr_string.split(".")
      if parts.size > 2
        # Has year - last part is the year
        year_part = parts.pop
        identifier_string = parts.join(" ") + ":#{year_part}"
      else
        # No year - just join with spaces
        identifier_string = parts.join(" ")
      end

      # Parse using the flavor's parser
      flavor_module.parse(identifier_string)
    end

    private

    # Base hash with common identifier attributes
    def base_hash
      # For supplement identifiers, we need to extract base document's number/year
      # For base identifiers, use their own number/year
      base_identifier_data = extract_base_identifier_data

      hash = {
        flavor: extract_flavor,
        publisher: extract_publisher,
        copublishers: extract_copublishers,
        number: base_identifier_data[:number],
        part: base_identifier_data[:part],
        subpart: extract_subpart,
        year: base_identifier_data[:year],
        month: base_identifier_data[:month],
        edition: extract_edition,
        version: extract_version,
        stage: extract_stage,
        languages: extract_languages,
      }

      # Only add type if this is NOT a supplement identifier
      # (supplements get their type from the supplements array)
      unless has_supplements?
        hash[:type] = extract_type
      end

      # type_info is available for all identifiers
      hash[:type_info] = extract_type_info

      # Add series for NIST identifiers
      hash[:series] = extract_series if respond_to?(:series)

      # Add year format flags for CSA (to preserve 2-digit vs 4-digit year format)
      if respond_to?(:original_year_4digit)
        hash[:original_year_4digit] = original_year_4digit
      end
      if respond_to?(:year_format)
        hash[:year_format] = year_format
      end

      hash
    end

    # Extract base document's data (for supplement identifiers, this walks down to the base)
    def extract_base_identifier_data
      # If this is a base identifier (no supplements), return its own data
      unless has_supplements?
        return { number: extract_number, part: extract_part, year: extract_year,
                 month: extract_month }
      end

      # Walk down to find the base identifier (handle both base_identifier and base)
      current = self
      while current.respond_to?(:base_identifier) && current.base_identifier
        current = current.base_identifier
      end
      # Also handle ETSI which uses :base instead of :base_identifier
      while current.respond_to?(:base) && current.base
        current = current.base
      end

      # current is now the base document (InternationalStandard, etc.)
      # Use the same extraction methods for consistency
      {
        number: extract_number_from_identifier(current),
        part: extract_part_from_identifier(current),
        # Use date.year like extract_year does
        year: if current.respond_to?(:date) && current.date
                current.date.year.to_s
              else
                (current.respond_to?(:year) && current.year ? current.year.to_s : nil)
              end,
        month: current.respond_to?(:date) && current.date.respond_to?(:month) ? current.date.month.to_s : nil,
      }
    end

    # Helper to extract number from another identifier
    def extract_number_from_identifier(identifier)
      return nil unless identifier

      # Use the identifier's extract_number method if it exists
      if identifier.respond_to?(:extract_number, true)
        return identifier.send(:extract_number)
      end

      # Fallback logic for identifiers without extract_number
      if identifier.respond_to?(:gum_number) && identifier.gum_number
        return identifier.gum_number.respond_to?(:value) ? identifier.gum_number.value : identifier.gum_number.to_s
      end

      if identifier.respond_to?(:number) && identifier.number
        return identifier.number.value if identifier.number.respond_to?(:value)

        return identifier.number.to_s
      end
      if identifier.respond_to?(:code) && identifier.code
        return identifier.code.to_s if !identifier.code.respond_to?(:number)
        return identifier.code.number.to_s if identifier.code.respond_to?(:number)
      end

      nil
    end

    # Helper to extract part from another identifier
    def extract_part_from_identifier(identifier)
      return nil unless identifier

      if identifier.respond_to?(:extract_part, true)
        return identifier.send(:extract_part)
      end

      return nil unless identifier.respond_to?(:part)
      return identifier.part.value if identifier.part.respond_to?(:value)
      return identifier.part if identifier.part.is_a?(String)

      nil
    end

    # Extract supplements as structured hash
    def supplements_hash
      return {} unless has_supplements?

      supplements = []
      # Start with current identifier (it IS a supplement)
      current = self
      supplements << supplement_hash(current)

      # Walk down the chain to collect all other supplements
      while current.respond_to?(:base_identifier) && current.base_identifier
        current = current.base_identifier
        # Include base_identifier only if it's also a supplement
        supplements << supplement_hash(current) if current.respond_to?(:base_identifier) && current.base_identifier
      end

      { supplements: supplements }
    end

    # Convert single supplement to hash
    def supplement_hash(supplement)
      {
        type: extract_supplement_type(supplement),
        number: extract_supplement_number(supplement),
        year: extract_supplement_year(supplement),
        stage: extract_supplement_stage(supplement),
      }.compact
    end

    # Metadata hash with URN and other derived data
    def metadata_hash
      hash = {}
      hash[:urn] = to_urn if respond_to?(:to_urn)
      hash[:mr_string] = to_mr_string
      hash[:typed_stage] = typed_stage_hash if respond_to?(:typed_stage)
      hash
    end

    # Extract flavor from class name
    def extract_flavor
      # Get class name and extract flavor (e.g., "Pubid::Iso::Identifiers::InternationalStandard" -> "iso")
      class_name = self.class.name.to_s
      parts = class_name.split("::")

      # Find the flavor part (second position for namespaced identifiers)
      if parts.size >= 2
        parts[1].downcase
      else
        "unknown"
      end
    end

    # Extract type from class or typed_stage
    def extract_type
      return nil unless respond_to?(:type) && type

      # Handle IEEE where type is a String
      return type.to_s if type.is_a?(String)

      # Handle AMCA/ASHRAE where type is a Hash
      return type[:key].to_s if type.is_a?(Hash) && type[:key]

      # Handle ISO/IEC where type is a Type component
      # Use abbr if present and non-empty, otherwise use type_code
      if type&.abbr && !type.abbr.empty?
        type.abbr
      elsif type&.type_code
        type.type_code.to_s
      end
    end

    # Extract publisher as string
    def extract_publisher
      return publisher.to_s if respond_to?(:publisher) && publisher
      # CSA uses publisher_prefix
      return publisher_prefix.to_s if respond_to?(:publisher_prefix) && publisher_prefix

      nil
    end

    # Extract copublishers as array of strings
    def extract_copublishers
      # Handle copublishers (array of Publisher components)
      return copublishers.map(&:to_s) if respond_to?(:copublishers) && copublishers.is_a?(Array) && copublishers.any?

      # Handle copublisher (array of Publisher components, different naming)
      return copublisher.map(&:to_s) if respond_to?(:copublisher) && copublisher.is_a?(Array) && copublisher.any?

      nil
    end

    # Extract number value
    def extract_number
      # Handle JCGM GumGuide which uses gum_number attribute
      if respond_to?(:gum_number) && gum_number
        return gum_number.respond_to?(:value) ? gum_number.value : gum_number.to_s
      end
      # Handle ETSI which uses @code as a Code component with to_s that includes parts
      # Check this BEFORE number.to_s because ETSI supplements have both code and number
      # where number is the supplement number, not the document number
      if respond_to?(:code) && code&.respond_to?(:to_s)
        return code.to_s
      end
      # Handle number attribute (most flavors)
      return number.value if respond_to?(:number) && number.respond_to?(:value)
      # Handle integer number (Plateau, etc.)
      return number.to_s if respond_to?(:number) && number

      nil
    end

    # Extract part value
    def extract_part
      return nil unless respond_to?(:part)
      return part.value if part.respond_to?(:value)
      # For flavors using plain string attributes (like CCSDS)
      return part if part.is_a?(String)

      nil
    end

    # Extract subpart value
    def extract_subpart
      return nil unless respond_to?(:subpart)
      return subpart.value if subpart.respond_to?(:value)
      # For flavors using plain string attributes (like CCSDS)
      return subpart if subpart.is_a?(String)

      nil
    end

    # Extract year from date
    def extract_year
      # Most flavors use date.year
      return date.year if respond_to?(:date) && date

      # IEEE/NIST use year directly
      year.to_s if respond_to?(:year) && year
    end

    # Extract month from date
    def extract_month
      return nil unless respond_to?(:date) && date
      return date.month if date.respond_to?(:month)

      nil
    end

    # Extract edition
    def extract_edition
      edition&.to_s if respond_to?(:edition)
    end

    # Extract version
    def extract_version
      version&.to_s if respond_to?(:version)
    end

    # Extract stage information
    def extract_stage
      return nil unless respond_to?(:stage) && stage

      {
        code: stage.stage_code,
        abbr: stage.abbr,
        name: stage.name,
        harmonized_stages: stage.harmonized_stages,
      }.compact
    end

    # Extract series (for NIST and similar flavors)
    # NIST has series.number, ITU has series.series (string value)
    def extract_series
      return nil unless respond_to?(:series) && series

      # Try number first (NIST)
      return series.number if series.respond_to?(:number)

      # If series doesn't have number, try series attribute (ITU)
      return series.series if series.respond_to?(:series)

      # Fallback to to_s
      series.to_s
    end

    # Extract type information
    def extract_type_info
      return nil unless respond_to?(:type) && type

      # Handle IEEE where type is a String
      return nil if type.is_a?(String) # IEEE doesn't have type_info structure

      # Handle AMCA/ASHRAE where type is a Hash
      if type.is_a?(Hash)
        return {
          key: type[:key],
          title: type[:title],
          short: type[:short],
        }.compact
      end

      # Handle ISO/IEC where type is a Type component with type_code
      if type.respond_to?(:type_code)
        return {
          code: type.type_code,
          abbr: type.abbr,
          name: type.name,
        }.compact
      end

      # Handle SAE and others where type only has abbr
      result = {}
      result[:abbr] = type.abbr if type.respond_to?(:abbr)
      result
    end

    # Extract languages as array
    def extract_languages
      return nil unless respond_to?(:languages) && languages&.any?

      # Use original_code if available (preserves original case like E/F/R)
      languages.map do |l|
        l.respond_to?(:original_code) && l.original_code ? l.original_code : l.to_s
      end
    end

    # Check if identifier has supplements
    def has_supplements?
      (respond_to?(:base_identifier) && base_identifier) || (respond_to?(:base) && base)
    end

    # Machine-readable publisher
    def mr_publisher
      return publisher.to_s if respond_to?(:publisher) && publisher
      # CSA uses publisher_prefix
      return publisher_prefix.to_s if respond_to?(:publisher_prefix) && publisher_prefix

      nil
    end

    # Machine-readable type
    def mr_type
      return nil unless respond_to?(:typed_stage)

      typed_stage&.type_code
    end

    # Machine-readable number
    def mr_number
      # Handle JCGM GumGuide which uses gum_number attribute
      if respond_to?(:gum_number) && gum_number
        return "gum.#{gum_number.respond_to?(:value) ? gum_number.value : gum_number.to_s}"
      end
      # Handle ETSI which uses @code as a Code component with to_s that includes parts
      # Check this BEFORE number.to_s because ETSI supplements have both code and number
      if respond_to?(:code) && code&.respond_to?(:to_s)
        return code.to_s
      end
      # Handle number attribute (most flavors)
      return number.value if respond_to?(:number) && number.respond_to?(:value)
      # Handle integer number (Plateau, etc.)
      return number.to_s if respond_to?(:number) && number

      nil
    end

    # Machine-readable part
    def mr_part
      return nil unless respond_to?(:part)
      return part.value if part.respond_to?(:value)
      # For flavors using plain string attributes (like CCSDS)
      return part if part.is_a?(String)

      nil
    end

    # Machine-readable year
    def mr_year
      # Most flavors use date.year
      return date.year if respond_to?(:date) && date

      # IEEE/NIST use year directly
      year.to_s if respond_to?(:year) && year
    end

    # Extract supplement type
    def extract_supplement_type(supplement)
      return nil unless supplement.class

      # Get class name without namespace
      class_name = supplement.class.name.to_s
      parts = class_name.split("::")
      simple_name = parts.last
      # Convert camel case to snake case (Amendment -> amendment)
      # For simple single-word types, just downcase
      # For compound types like TechnicalSpecification, insert underscores
      result = simple_name&.gsub(/([a-z])([A-Z])/, '\1_\2')
      result&.downcase
    end

    # Extract supplement number
    def extract_supplement_number(supplement)
      return nil unless supplement.respond_to?(:number)
      return supplement.number.to_s if supplement.number.is_a?(Integer)

      supplement.number&.value
    end

    # Extract supplement year
    def extract_supplement_year(supplement)
      supplement.date&.year if supplement.respond_to?(:date)
    end

    # Extract supplement stage
    def extract_supplement_stage(supplement)
      return nil unless supplement.respond_to?(:stage) && supplement.stage

      {
        code: supplement.stage.stage_code,
        abbr: supplement.stage.abbr,
        name: supplement.stage.name,
        harmonized_stages: supplement.stage.harmonized_stages,
      }.compact
    end

    # Typed stage as hash
    def typed_stage_hash
      return nil unless respond_to?(:typed_stage) && typed_stage

      hash = {
        code: typed_stage.type_code, # For backward compatibility
        stage_code: typed_stage.stage_code,
        type_code: typed_stage.type_code,
        abbr: typed_stage.abbr,
        name: typed_stage.name,
      }
      # Not all flavors have harmonized_stages (IEEE doesn't)
      if typed_stage.respond_to?(:harmonized_stages)
        hash[:harmonized_stages] =
          typed_stage.harmonized_stages
      end

      hash.compact
    end

    # Detect flavor from machine-readable string
    def self.detect_flavor_from_mr(mr_string)
      publisher = mr_string.split(".").first.upcase

      case publisher
      when "ISO"
        :iso
      when "IEC"
        :iec
      when "IEEE"
        :ieee
      when "NIST", "NBS"
        :nist
      when "BS"
        :bsi
      when "CEN"
        :cen
      when "JIS"
        :jis
      when "ETSI"
        :etsi
      when "ITU"
        :itu
      when "ANSI"
        :ansi
      when "OIML"
        :oiml
      when "CIE"
        :cie
      when "ASHRAE"
        :ashrae
      when "AMCA"
        :amca
      when "IDF"
        :idf
      when "IHO"
        :iho
      when "JCGM"
        :jcgm
      when "SAE"
        :sae
      when "ASME"
        :asme
      when "CSA"
        :csa
      when "API"
        :api
      when "ASTM"
        :astm
      when "PLATEAU"
        :plateau
      when "CCSDS"
        :ccsds
      else
        # Try to detect from other patterns
        :iso # Default to ISO
      end
    end
  end
end
