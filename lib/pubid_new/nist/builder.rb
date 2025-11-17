# frozen_string_literal: true

module PubidNew
  module Nist
    # Builder class for constructing NIST identifier scheme from parsed data
    # Single Responsibility: Transform parsed data into Scheme objects
    class Builder
      attr_reader :scheme_class

      def initialize(scheme_class = Scheme)
        @scheme_class = scheme_class
      end

      # Build a scheme object from parsed data
      # @param parsed [Hash, Array] the parsed identifier data
      # @return [Scheme] the constructed scheme object
      def build(parsed)
        # Parslet can return array of hashes - merge them
        parsed_hash = parsed.is_a?(Array) ? merge_parsed_array(parsed) : parsed
        attributes = extract_attributes(parsed_hash)
        scheme_class.new(**attributes)
      end

      private

      # Merge an array of parsed hashes into a single hash
      # @param parsed_array [Array<Hash>] array of parsed hashes
      # @return [Hash] merged hash
      def merge_parsed_array(parsed_array)
        parsed_array.inject({}) do |result, hash|
          result.merge(hash)
        end
      end

      # Extract and normalize attributes from parsed data
      # @param parsed [Hash] the parsed data
      # @return [Hash] normalized attributes for Scheme
      def extract_attributes(parsed)
        attributes = {}

        # Basic attributes
        attributes[:publisher] = extract_value(parsed[:publisher])
        attributes[:series] = extract_value(parsed[:series])
        attributes[:first_number] = extract_value(parsed[:first_number])
        attributes[:second_number] = extract_value(parsed[:second_number])

        # Optional attributes
        extract_optional_attribute(parsed, attributes, :volume)
        extract_optional_attribute(parsed, attributes, :part)
        extract_optional_attribute(parsed, attributes, :revision)
        extract_optional_attribute(parsed, attributes, :section)
        extract_optional_attribute(parsed, attributes, :appendix)
        extract_optional_attribute(parsed, attributes, :translation)
        extract_optional_attribute(parsed, attributes, :draft)
        extract_optional_attribute(parsed, attributes, :errata)
        extract_optional_attribute(parsed, attributes, :index)
        extract_optional_attribute(parsed, attributes, :insert)
        
        # Supplement needs special handling - empty array means "supp" with no suffix
        handle_supplement(parsed, attributes)

        # Handle version - can be simple or complex
        handle_version(parsed, attributes)

        # Handle edition - can have year/month/day
        handle_edition(parsed, attributes)

        # Handle update - can have number and year
        handle_update(parsed, attributes)

        # Handle addendum - can have number
        handle_addendum(parsed, attributes)

        attributes
      end

      # Extract a simple value from parsed data
      # @param value [Object] the value to extract
      # @return [String, nil] the extracted string value
      def extract_value(value)
        return nil if value.nil?
        return nil if value.is_a?(Array) && value.empty?
        
        # Handle arrays by joining elements
        if value.is_a?(Array)
          joined = value.map(&:to_s).join
          return joined if joined.length > 0
          return nil
        end
        
        str_value = value.to_s.strip
        str_value.length > 0 ? str_value : nil
      end

      # Extract optional attribute if present
      # @param parsed [Hash] the parsed data
      # @param attributes [Hash] the attributes hash to populate
      # @param key [Symbol] the attribute key
      def extract_optional_attribute(parsed, attributes, key)
        value = extract_value(parsed[key])
        attributes[key] = value if value
      end

      # Handle supplement - empty array means "supp" with no suffix
      def handle_supplement(parsed, attributes)
        return unless parsed.key?(:supplement)
        
        supp_val = parsed[:supplement]
        if supp_val.is_a?(Array) && supp_val.empty?
          # Empty array means "supp" was present but no suffix
          attributes[:supplement] = ""
        elsif supp_val
          value = extract_value(supp_val)
          attributes[:supplement] = value if value
        end
      end

      # Handle version attribute
      def handle_version(parsed, attributes)
        if parsed[:version]
          attributes[:version] = extract_value(parsed[:version])
        end
      end

      # Handle edition attributes (year, month, day, or simple edition number)
      def handle_edition(parsed, attributes)
        if parsed[:edition_year]
          attributes[:edition_year] = extract_value(parsed[:edition_year])
          attributes[:edition_month] = extract_value(parsed[:edition_month]) if parsed[:edition_month]
          attributes[:edition_day] = extract_value(parsed[:edition_day]) if parsed[:edition_day]
        end
        if parsed[:edition]
          attributes[:edition] = extract_value(parsed[:edition])
        end
      end

      # Handle update attributes (number and year)
      def handle_update(parsed, attributes)
        if parsed[:update].is_a?(Hash)
          attributes[:update_number] = extract_value(parsed[:update][:update_number])
          attributes[:update_year] = extract_value(parsed[:update][:update_year]) if parsed[:update][:update_year]
        elsif parsed[:update_number]
          attributes[:update_number] = extract_value(parsed[:update_number])
          attributes[:update_year] = extract_value(parsed[:update_year]) if parsed[:update_year]
        elsif parsed[:update]
          attributes[:update] = extract_value(parsed[:update])
        end
      end

      # Handle addendum attributes (number)
      def handle_addendum(parsed, attributes)
        if parsed[:addendum].is_a?(Hash)
          addendum_num = extract_value(parsed[:addendum][:addendum_number])
          if addendum_num && addendum_num.length > 0
            attributes[:addendum_number] = addendum_num
          else
            attributes[:addendum] = "true"
          end
        elsif parsed[:addendum_number]
          attributes[:addendum_number] = extract_value(parsed[:addendum_number])
        elsif parsed[:addendum]
          addendum_val = extract_value(parsed[:addendum])
          if addendum_val && addendum_val.length > 0
            attributes[:addendum_number] = addendum_val
          else
            attributes[:addendum] = "true"
          end
        end
      end
    end
  end
end