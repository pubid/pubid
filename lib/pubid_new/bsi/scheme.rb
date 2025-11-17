module PubidNew
  module Bsi
    class Scheme
      # Transform parsed data into structured hash
      def self.transform(parsed)
        result = {}
        
        # Handle national annex
        if parsed[:national_annex]
          na_data = parsed[:national_annex]
          na_hash = { type: "NA" }
          if na_data[:na_supplement]
            na_hash[:supplement] = transform_supplement(na_data[:na_supplement])
          end
          result[:national_annex] = na_hash
        end

        # Document type
        if parsed[:type]
          type_str = parsed[:type].to_s
          result[:type] = normalize_type(type_str)
        end

        # Number and part
        result[:number] = parsed[:number].to_s if parsed[:number]
        result[:part] = parsed[:part].to_s if parsed[:part]
        result[:second_number] = parsed[:second_number].to_s if parsed[:second_number]

        # Year and month
        result[:year] = parsed[:year].to_s if parsed[:year]
        result[:month] = parsed[:month].to_s if parsed[:month]

        # Edition (for Flex)
        result[:edition] = parsed[:edition].to_s if parsed[:edition]

        # Supplements
        if parsed[:supplements]
          supplements = parsed[:supplements].is_a?(Array) ? parsed[:supplements] : [parsed[:supplements]]
          result[:supplements] = supplements.map do |s|
            # Extract from nested :supplement key if present
            supp_data = s[:supplement] || s
            transform_supplement(supp_data)
          end.compact
        end

        # Adopted document
        if parsed[:adopted]
          adopted_str = parsed[:adopted].to_s
          result[:adopted] = parse_adopted(adopted_str)
        end

        # Expert commentary
        result[:expert_commentary] = true if parsed[:expert_commentary]

        # Tracked changes
        result[:tracked_changes] = true if parsed[:tracked_changes]

        # Translation
        if parsed[:translation]
          trans = parsed[:translation].to_s
          result[:translation] = trans.capitalize
        end

        # PDF marker
        result[:pdf] = true if parsed[:pdf]

        result
      end

      private

      def self.normalize_type(type_str)
        case type_str
        when "BS", "BSI"
          "BS"
        when "PAS"
          "PAS"
        when "PD"
          "PD"
        when "DD"
          "DD"
        when "Flex", "BSI Flex"
          "BSI Flex"
        else
          type_str
        end
      end

      def self.transform_supplement(supp_data)
        return nil unless supp_data

        if supp_data[:amd_number]
          # Extract year from nested structure if present
          year_value = if supp_data[:amd_year]
            supp_data[:amd_year].is_a?(Hash) ? supp_data[:amd_year][:year].to_s : supp_data[:amd_year].to_s
          end
          
          {
            type: "amendment",
            number: supp_data[:amd_number].to_s,
            year: year_value
          }
        elsif supp_data[:cor_number]
          # Extract year from nested structure if present
          year_value = if supp_data[:cor_year]
            supp_data[:cor_year].is_a?(Hash) ? supp_data[:cor_year][:year].to_s : supp_data[:cor_year].to_s
          end
          
          {
            type: "corrigendum",
            number: supp_data[:cor_number].to_s,
            year: year_value
          }
        end
      end

      def self.parse_adopted(adopted_str)
        # Try to parse as IEC first
        begin
          return { flavor: "iec", identifier: PubidNew::Iec.parse(adopted_str) }
        rescue Parslet::ParseFailed, StandardError
          # Continue to ISO
        end

        # Try ISO
        begin
          return { flavor: "iso", identifier: PubidNew::Iso.parse(adopted_str) }
        rescue Parslet::ParseFailed, StandardError
          # Continue to CEN
        end

        # Try CEN
        begin
          return { flavor: "cen", identifier: PubidNew::Cen.parse(adopted_str) }
        rescue Parslet::ParseFailed, StandardError
          # Return as string if all parsers fail
          { flavor: "unknown", text: adopted_str }
        end
      end

      def self.normalize_year(year_str)
        return nil unless year_str
        
        year = year_str.to_i
        if year < 100
          # Two-digit year: 00-50 means 2000-2050, 51-99 means 1951-1999
          year < 51 ? 2000 + year : 1900 + year
        else
          year
        end
      end
    end
  end
end