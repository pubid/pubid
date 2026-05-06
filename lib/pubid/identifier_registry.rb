# frozen_string_literal: true

require_relative "identifier_metadata"

module Pubid
  # Global registry of all identifier types across all flavors
  # Provides searchable index for machine-readable lookups
  class IdentifierRegistry
    class << self
      # Register an identifier class with its metadata
      # @param identifier_class [Class] The identifier class
      # @param metadata [Hash] Metadata attributes
      def register(identifier_class, **metadata)
        # Extract class name from full class name
        identifier_class_name = identifier_class.name.to_s.split("::")&.last

        all_identifiers[identifier_class] = IdentifierMetadata::Metadata.new(
          flavor: metadata.fetch(:flavor),
          identifier_class: identifier_class_name,
          **metadata,
        )

        # Index by various keys for fast lookup
        index_by_flavor(metadata[:flavor], identifier_class)
        if metadata[:type_key]
          index_by_type_key(metadata[:type_key],
                            identifier_class)
        end
        index_by_abbr(metadata[:abbr], identifier_class) if metadata[:abbr]

        identifier_class
      end

      # Find identifier class by flavor and type key
      # @param flavor [String, Symbol] The flavor
      # @param type_key [String, Symbol] The type key
      # @return [Class, nil]
      def find_by_type(flavor, type_key)
        flavor_index[flavor.to_s]&.dig(type_key.to_s)
      end

      # Find identifier class by abbreviation
      # @param flavor [String, Symbol] The flavor
      # @param abbr [String] The abbreviation
      # @return [Array<Class>] All matching classes
      def find_by_abbr(flavor, abbr)
        abbr_index[flavor.to_s]&.dig(abbr.to_s.downcase) || []
      end

      # Get all identifiers for a flavor
      # @param flavor [String, Symbol] The flavor
      # @return [Array<Class>]
      def all_for_flavor(flavor)
        flavor_index[flavor.to_s]&.values || []
      end

      # Get all registered identifiers
      # @return [Hash<Class, Metadata>]
      def all_identifiers
        @all_identifiers ||= {}
      end

      # Get metadata for an identifier class
      # @param identifier_class [Class] The identifier class
      # @return [Metadata, nil]
      def metadata_for(identifier_class)
        all_identifiers[identifier_class]
      end

      # Search identifiers by criteria
      # @param criteria [Hash] Search criteria
      # @option criteria [String, Symbol] :flavor Filter by flavor
      # @option criteria [String, Symbol] :type_key Filter by type key
      # @option criteria [String] :abbr Filter by abbreviation
      # @option criteria [String] :title Filter by title (partial match)
      # @option criteria [Boolean] :base_class Filter by base class status
      # @option criteria [Boolean] :supplement_class Filter by supplement class status
      # @return [Array<Hash>] Array of {class: Class, metadata: Metadata}
      def search(**criteria)
        results = []

        all_identifiers.each do |klass, metadata|
          matches = true

          if criteria[:flavor]
            matches &= metadata.flavor.to_s == criteria[:flavor].to_s
          end

          if criteria[:type_key]
            matches &= metadata.type_key.to_s == criteria[:type_key].to_s
          end

          if criteria[:abbr]
            matches &= metadata.abbr.map(&:to_s).map(&:downcase).include?(criteria[:abbr].to_s.downcase)
          end

          if criteria[:title]
            matches &= metadata.title.to_s.downcase.include?(criteria[:title].to_s.downcase)
          end

          if criteria[:base_class]
            matches &= !metadata.base_class.nil? == criteria[:base_class]
          end

          if criteria[:supplement_class]
            matches &= !metadata.supplement_class.nil? == criteria[:supplement_class]
          end

          results << { class: klass, metadata: metadata } if matches
        end

        results
      end

      # Export registry to machine-readable format (JSON)
      # @return [String] JSON representation
      def to_json(*args)
        all_identifiers.values.map(&:to_hash).to_json(*args)
      end

      # Export registry to machine-readable format (YAML)
      # @return [String] YAML representation
      def to_yaml
        require "json"
        hash = all_identifiers.values.map(&:to_h)
        # Convert to YAML format (basic implementation)
        hash.map(&:to_json).join("\n")
      end

      # Clear all registrations (useful for testing)
      def clear!
        @all_identifiers = {}
        @flavor_index = nil
        @type_key_index = nil
        @abbr_index = nil
      end

      # Generate a summary report
      # @return [String] Human-readable summary
      def summary
        flavors = all_identifiers.values.map(&:flavor).uniq.sort
        total = all_identifiers.size

        summary = "Identifier Registry Summary\n"
        summary += "#{'=' * 50}\n"
        summary += "Total identifiers: #{total}\n"
        summary += "Flavors: #{flavors.join(', ')}\n\n"

        flavors.each do |flavor|
          flavor_ids = all_identifiers.values.select do |m|
            m.flavor.to_s == flavor
          end
          summary += "#{flavor.upcase} (#{flavor_ids.size}):\n"
          flavor_ids.sort_by(&:type_key).each do |metadata|
            summary += "  - #{metadata.type_key}: #{metadata.title}\n"
          end
        end

        summary
      end

      private

      def flavor_index
        @flavor_index ||= Hash.new { |h, k| h[k] = {} }
      end

      def type_key_index
        @type_key_index ||= Hash.new { |h, k| h[k] = {} }
      end

      def abbr_index
        @abbr_index ||= Hash.new do |h, k|
          h[k] = Hash.new do |h2, k2|
            h2[k2] = []
          end
        end
      end

      def index_by_flavor(flavor, identifier_class)
        flavor_index[flavor.to_s][:_all] ||= []
        flavor_index[flavor.to_s][:_all] << identifier_class
      end

      def index_by_type_key(type_key, identifier_class)
        flavor = all_identifiers[identifier_class].flavor
        flavor_index[flavor.to_s][type_key.to_s] = identifier_class
      end

      def index_by_abbr(abbr, identifier_class)
        flavor = all_identifiers[identifier_class].flavor
        Array(abbr).each do |a|
          abbr_index[flavor.to_s][a.to_s.downcase] << identifier_class
        end
      end
    end
  end
end
