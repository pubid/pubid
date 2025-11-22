# frozen_string_literal: true

module PubidNew
  module Nist
    # Builder class for constructing NIST identifier scheme from parsed data
    # Single Responsibility: Transform parsed data into identifier objects
    class Builder
      attr_reader :identifier_class

      def initialize(identifier_class = Identifiers::Base)
        @identifier_class = identifier_class
      end

      # Build an identifier object from parsed data
      # @param parsed [Hash, Array] the parsed identifier data
      # @return [Identifiers::Base] the constructed identifier object
      def build(parsed)
        # Parslet can return array of hashes - merge them
        parsed_hash = parsed.is_a?(Array) ? merge_parsed_array(parsed) : parsed
        attributes = extract_attributes(parsed_hash)
        identifier_class.new(**attributes)
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
      # @return [Hash] normalized attributes for identifier
      def extract_attributes(parsed)
        attributes = {}

        # Basic attributes
        attributes[:publisher] = extract_value(parsed[:publisher])
        attributes[:series] = extract_value(parsed[:series])

        # Handle special patterns in first_number before normal extraction
        handle_special_first_number(parsed, attributes)

        attributes[:first_number] = extract_value(parsed[:first_number])
        attributes[:second_number] = extract_value(parsed[:second_number])
        handle_crpl_range(parsed, attributes)

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

      # Handle special patterns embedded in first_number
      def handle_special_first_number(parsed, attributes)
        first_num = extract_value(parsed[:first_number])
        return unless first_num

        # Pattern: "154supprev" - supplement with revision
        if first_num =~ /^(\d+)supprev$/
          attributes[:first_number] = $1
          attributes[:supplement] = ""
          attributes[:supplement_has_revision] = true
          parsed[:first_number] = $1  # Update parsed to avoid re-extraction
        # Pattern: "13e2revJune1908" - edition with revision and date
        elsif first_num =~ /^(\d+)e(\d+)rev([A-Za-z]+)(\d+)$/
          attributes[:first_number] = $1
          attributes[:edition] = $2
          attributes[:edition_month] = $3
          attributes[:edition_year] = $4
          parsed[:first_number] = $1
        end
      end

      # Handle CRPL range notation
      def handle_crpl_range(parsed, attributes)
        return unless parsed[:crpl_range]

        crpl_range = extract_value(parsed[:crpl_range])
        if crpl_range
          # For "1-2_3-1", we want to store it as a range notation
          attributes[:range_notation] = "-#{crpl_range}"
        end
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

      # Handle supplement - enhanced to support date ranges, dates with months/years, etc.
      def handle_supplement(parsed, attributes)
        return unless parsed.key?(:supplement) || parsed.key?(:supplement_date_range) ||
                      parsed.key?(:supplement_date) || parsed.key?(:supplement_slash_year) ||
                      parsed.key?(:supplement_with_rev)

        # Handle supplement with revision: supprev
        if parsed[:supplement_with_rev]
          attributes[:supplement] = ""
          attributes[:supplement_has_revision] = true
        # Handle date range pattern (e.g., Jan1924-Jan1926)
        elsif parsed[:supplement_date_range]
          range_data = parsed[:supplement_date_range]
          if range_data.is_a?(Hash)
            month_start = extract_value(range_data[:supp_month_start])
            year_start = extract_value(range_data[:supp_year_start])
            month_end = extract_value(range_data[:supp_month_end])
            year_end = extract_value(range_data[:supp_year_end])

            attributes[:supplement_date_range_start] = "#{month_start}#{year_start}" if month_start && year_start
            attributes[:supplement_date_range_end] = "#{month_end}#{year_end}" if month_end && year_end
          end
        # Handle supplement with month and year (e.g., Jan1924)
        elsif parsed[:supplement_date]
          date_data = parsed[:supplement_date]
          if date_data.is_a?(Hash)
            month = extract_value(date_data[:supp_month])
            year = extract_value(date_data[:supp_year])
            attributes[:supplement] = "#{month}#{year}" if month && year
          end
        # Handle supplement with number/year (e.g., 3/1926)
        elsif parsed[:supplement_slash_year]
          slash_data = parsed[:supplement_slash_year]
          if slash_data.is_a?(Hash)
            number = extract_value(slash_data[:supp_number])
            year = extract_value(slash_data[:supp_year])
            attributes[:supplement] = "#{number}/#{year}" if number && year
          end
        # Handle supplement with just year
        elsif parsed[:supp_year]
          attributes[:supplement] = extract_value(parsed[:supp_year])
        # Handle regular supplement patterns
        elsif parsed[:supplement]
          supp_val = parsed[:supplement]
          if supp_val.is_a?(Array) && supp_val.empty?
            # Empty array means "supp" was present but no suffix
            attributes[:supplement] = ""
          elsif supp_val
            value = extract_value(supp_val)
            attributes[:supplement] = value if value
          end
        # Handle supplement_suffix
        elsif parsed[:supplement_suffix]
          attributes[:supplement] = extract_value(parsed[:supplement_suffix])
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