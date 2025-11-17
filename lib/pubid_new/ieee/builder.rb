# frozen_string_literal: true

module PubidNew
  module Ieee
    # Builder class for constructing IEEE identifier scheme from parsed data
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

        # Handle publishers
        if parsed[:publishers]
          pub_data = parsed[:publishers]
          attributes[:publisher] = extract_value(pub_data[:publisher])
          
          if pub_data[:copublishers]
            copubs = pub_data[:copublishers]
            copubs = [copubs] unless copubs.is_a?(Array)
            attributes[:copublishers] = copubs.map { |cp| extract_value(cp[:copublisher]) }.compact
          end
        elsif parsed[:publisher]
          attributes[:publisher] = extract_value(parsed[:publisher])
        end

        # Basic attributes
        attributes[:number] = extract_value(parsed[:number])
        attributes[:type] = extract_value(parsed[:type])
        attributes[:draft_status] = extract_value(parsed[:draft_status])

        # Optional attributes
        extract_optional(parsed, attributes, :part)
        extract_optional(parsed, attributes, :subpart)
        extract_optional(parsed, attributes, :year)
        extract_optional(parsed, attributes, :month)
        extract_optional(parsed, attributes, :day)
        extract_optional(parsed, attributes, :edition)
        extract_optional(parsed, attributes, :revision)

        # Handle draft (can be complex)
        handle_draft(parsed, attributes)

        # Handle corrigendum
        handle_corrigendum(parsed, attributes)

        # Handle amendment
        handle_amendment(parsed, attributes)

        # Handle reaffirmed
        handle_reaffirmed(parsed, attributes)

        # Handle additional parameters
        handle_parameters(parsed, attributes)

        # Redline
        attributes[:redline] = true if parsed[:redline]

        attributes
      end

      # Extract a simple value from parsed data
      # @param value [Object] the value to extract
      # @return [String, nil] the extracted string value
      def extract_value(value)
        return nil if value.nil?
        return nil if value.is_a?(Array) && value.empty?
        
        if value.is_a?(Array)
          joined = value.map(&:to_s).join
          return joined.length > 0 ? joined : nil
        end
        
        str_value = value.to_s.strip
        str_value.length > 0 ? str_value : nil
      end

      # Extract optional attribute if present
      def extract_optional(parsed, attributes, key)
        value = extract_value(parsed[key])
        attributes[key] = value if value
      end

      # Handle draft information
      def handle_draft(parsed, attributes)
        return unless parsed[:draft]
        
        draft_data = parsed[:draft]
        
        # Draft can be an array of hash elements or a single hash
        if draft_data.is_a?(Array)
          # Merge all elements in the array
          merged = draft_data.inject({}) { |result, elem| result.merge(elem) }
          draft_data = merged
        end
        
        if draft_data.is_a?(Hash)
          # Extract draft_version
          if draft_data[:draft_version]
            dv = draft_data[:draft_version]
            if dv.is_a?(Array)
              attributes[:draft_version] = dv.map { |v| extract_value(v) }.join
            else
              attributes[:draft_version] = extract_value(dv)
            end
          end
          attributes[:revision] = extract_value(draft_data[:revision]) if draft_data[:revision]
          attributes[:month] = extract_value(draft_data[:month]) if draft_data[:month]
          attributes[:year] = extract_value(draft_data[:year]) if draft_data[:year]
          attributes[:day] = extract_value(draft_data[:day]) if draft_data[:day]
        else
          attributes[:draft] = extract_value(draft_data)
        end
      end

      # Handle corrigendum information
      def handle_corrigendum(parsed, attributes)
        if parsed[:corrigendum].is_a?(Hash)
          cor_data = parsed[:corrigendum]
          attributes[:cor_number] = extract_value(cor_data[:cor_number])
          attributes[:cor_year] = extract_value(cor_data[:cor_year]) if cor_data[:cor_year]
        elsif parsed[:corrigendum]
          attributes[:corrigendum] = extract_value(parsed[:corrigendum])
        end
      end

      # Handle amendment information
      def handle_amendment(parsed, attributes)
        if parsed[:amendment].is_a?(Hash)
          amd_data = parsed[:amendment]
          attributes[:amd_number] = extract_value(amd_data[:amd_number])
          attributes[:amd_year] = extract_value(amd_data[:amd_year]) if amd_data[:amd_year]
        elsif parsed[:amendment]
          attributes[:amendment] = extract_value(parsed[:amendment])
        end
      end

      # Handle reaffirmed information
      def handle_reaffirmed(parsed, attributes)
        if parsed[:reaffirmed].is_a?(Hash)
          reaf_data = parsed[:reaffirmed]
          attributes[:reaffirmed] = extract_value(reaf_data[:year])
        elsif parsed[:reaffirmed]
          attributes[:reaffirmed] = extract_value(parsed[:reaffirmed])
        end
      end

      # Handle additional parameters
      def handle_parameters(parsed, attributes)
        if parsed[:parameters].is_a?(Hash)
          param_data = parsed[:parameters]
          attributes[:revision_of] = extract_value(param_data[:revision_of]) if param_data[:revision_of]
          attributes[:amendment_to] = extract_value(param_data[:amendment_to]) if param_data[:amendment_to]
          attributes[:adoption] = extract_value(param_data[:adoption]) if param_data[:adoption]
          attributes[:note] = extract_value(param_data[:note]) if param_data[:note]
        end
      end
    end
  end
end