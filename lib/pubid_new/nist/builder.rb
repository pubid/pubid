# frozen_string_literal: true

require_relative "components/publisher"
require_relative "components/code"
require_relative "../components/date"
require_relative "components/stage"
require_relative "components/edition"
require_relative "components/version"
require_relative "components/update"
require_relative "components/translation"

module PubidNew
  module Nist
    # Builder class for constructing NIST identifier objects from parsed data
    # Single Responsibility: Transform parsed data into identifier objects
    #
    # CRITICAL ARCHITECTURE PRINCIPLE:
    # Builder NEVER makes business logic decisions.
    # Builder ONLY casts parsed data to domain objects.
    class Builder
      # Translation normalization map (V1 compatibility)
      TRANSLATION_MAP = {
        "es" => "spa",
        "pt" => "por",
        "id" => "ind",
        "chi" => "zho",
        "viet" => "vie",
        "port" => "por",
        "esp" => "spa"
      }.freeze

      def initialize(scheme)
        @scheme = scheme
      end

      # Build an identifier object from parsed data
      # @param parsed [Hash, Array] the parsed identifier data
      # @return [Identifiers::Base] the constructed identifier object
      def build(parsed)
        # Parslet can return array of hashes - merge them
        parsed_hash = parsed.is_a?(Array) ? merge_parsed_array(parsed) : parsed

        # Locate the appropriate identifier class via Scheme
        identifier = @scheme.locate_identifier_klass(parsed_hash).new

        # Track first_number and second_number for building compound number
        first_num = nil
        second_num = nil
        extracted_revision = nil

        # Cast and assign all attributes
        parsed_hash.each_pair do |key, value|
          realized_components = cast(key.to_sym, value)
          next if realized_components.nil?

          # Track number components
          if key == :first_number && realized_components.is_a?(Components::Code)
            first_num = realized_components
          elsif key == :second_number && realized_components.is_a?(Components::Code)
            second_num = realized_components
          end

          # Handle composite hash returns (multiple related values)
          case realized_components
          when Hash
            realized_components.each_pair do |sub_key, sub_value|
              # Track first_number from hash returns
              if sub_key == :first_number && sub_value.is_a?(Components::Code)
                first_num = sub_value
              # Track second_number from hash returns
              elsif sub_key == :second_number && sub_value.is_a?(Components::Code)
                second_num = sub_value
              # Track revision extraction
              elsif sub_key == :revision
                extracted_revision = sub_value
              end
              identifier.send("#{sub_key}=", sub_value) if identifier.respond_to?("#{sub_key}=")
            end
          else
            identifier.send("#{key}=", realized_components) if identifier.respond_to?("#{key}=")
          end
        end

        # Build compound number from first_number and second_number
        if first_num && !identifier.number
          if second_num
            compound_value = "#{first_num.value}-#{second_num.value}"
            identifier.number = Components::Code.new(number: compound_value)
          else
            identifier.number = first_num
          end
        end

        # Apply extracted revision if not already set
        if extracted_revision && !identifier.revision
          identifier.revision = extracted_revision
        end

        identifier
      end

      private

      # Merge an array of parsed hashes into a single hash
      # @param parsed_array [Array<Hash>] array of parsed hashes
      # @return [Hash] merged hash
      def merge_parsed_array(parsed_array)
        parsed_array.inject({}) { |result, hash| result.merge(hash) }
      end

      # Cast parsed value to appropriate component type
      # ALL conversions happen in this single method
      # @param type [Symbol] the parameter type
      # @param value [Object] the parsed value
      # @return [Object, Hash, nil] the cast component(s)
      def cast(type, value)
        case type
        when :publisher
          return nil if value.nil? || value.to_s.strip.empty?
          Components::Publisher.new(publisher: value.to_s)

        when :series
          return nil if value.nil? || value.to_s.strip.empty?

          str_value = value.to_s
          publisher_extracted = nil

          # For compound series like "NBS CIRC", extract publisher and series separately
          if str_value.start_with?("NBS ")
            publisher_extracted = "NBS"
            str_value = str_value.sub("NBS ", "")
          end

          # Return composite hash with both publisher and series if extracted
          if publisher_extracted
            {
              publisher: Components::Publisher.new(publisher: publisher_extracted),
              series: Components::Code.new(number: str_value)
            }
          else
            Components::Code.new(number: str_value)
          end

        when :first_number, :second_number
          return nil if value.nil? || value.to_s.strip.empty?

          str_value = value.to_s

          # Handle special patterns embedded in first_number
          if type == :first_number
            # Pattern: "154supprev" - supplement with revision
            if str_value =~ /^(\d+)supprev$/
              return {
                first_number: Components::Code.new(number: $1),
                supplement: "",
                supplement_has_revision: true
              }
            # Pattern: "13e2revJune1908" - edition with revision and date
            elsif str_value =~ /^(\d+)e(\d+)rev([A-Za-z]+)(\d+)$/
              return {
                first_number: Components::Code.new(number: $1),
                edition: $2,
                edition_month: $3,
                edition_year: $4
              }
            end
          end

          # Extract revision suffix from number (e.g., "53r5" → "53" + revision "5")
          if str_value =~ /^(.+?)(r\d+[a-z]?)$/i
            number_part = $1
            revision_part = $2
            return {
              type => Components::Code.new(number: number_part),
              revision: revision_part
            }
          end

          Components::Code.new(number: str_value)

        when :crpl_range
          return nil if value.nil? || value.to_s.strip.empty?
          # For "1-2_3-1", store as range notation
          "-#{value}"

        # ========== V2 COMPONENT CASTING ==========

        when :stage
          # Stage from nested hash with id and type
          return nil unless value.is_a?(Hash)
          stage_id = value[:stage_id]&.to_s&.downcase
          stage_type = value[:stage_type]&.to_s&.downcase
          return nil if stage_id.nil? || stage_type.nil? || stage_id.empty? || stage_type.empty?

          # Return as hash to set the stage attribute
          { stage: Components::Stage.new(id: stage_id, type: stage_type) }

        when :stage_id, :stage_type
          # These are captured by :stage, so skip individual processing
          nil

        when :parsed_format
          # Format detection result from parser
          value.to_s if value

        when :translation
          # V1 TRANSLATION NORMALIZATION
          return nil if value.nil? || value.to_s.strip.empty?

          code = value.to_s.strip.downcase
          # Apply normalization map (es → spa, pt → por, etc.)
          normalized_code = TRANSLATION_MAP[code] || code

          # Return as hash to set translation_component attribute
          { translation_component: Components::Translation.new(code: normalized_code) }

        when :version
          # Version component with dotted notation
          return nil if value.nil? || value.to_s.strip.empty?

          # Return as hash to set version_component attribute
          { version_component: Components::Version.new(value: value.to_s) }

        when :update
          # Update component with number, year, and optional month
          if value.is_a?(Hash)
            number = value[:update_number]&.to_i || 1
            year = value[:update_year]&.to_i
            month = value[:update_month]&.to_i

            # Only create if we have at least a number
            # Return as hash to set update_component attribute
            if number
              { update_component: Components::Update.new(number: number, year: year, month: month) }
            else
              nil
            end
          else
            # Simple string value - store to old update attribute for backward compat
            { update: value.to_s.strip } unless value.to_s.strip.empty?
          end

        when :update_number, :update_year, :update_month
          # Captured as part of :update processing
          nil

        # ========== END V2 COMPONENTS ==========

        when :volume, :part, :revision, :section, :appendix, :translation,
             :draft, :errata, :index, :insert, :edition, :version
          return nil if value.nil?
          return nil if value.is_a?(Array) && value.empty?

          str_value = value.to_s.strip
          return nil if str_value.empty?

          str_value

        when :supplement
          handle_supplement_cast(value)

        when :supplement_date_range
          return nil unless value.is_a?(Hash)

          month_start = value[:supp_month_start]&.to_s
          year_start = value[:supp_year_start]&.to_s
          month_end = value[:supp_month_end]&.to_s
          year_end = value[:supp_year_end]&.to_s

          {
            supplement_date_range_start: (month_start && year_start ? "#{month_start}#{year_start}" : nil),
            supplement_date_range_end: (month_end && year_end ? "#{month_end}#{year_end}" : nil)
          }

        when :supplement_date
          return nil unless value.is_a?(Hash)

          month = value[:supp_month]&.to_s
          year = value[:supp_year]&.to_s

          month && year ? "#{month}#{year}" : nil

        when :supplement_slash_year
          return nil unless value.is_a?(Hash)

          number = value[:supp_number]&.to_s
          year = value[:supp_year]&.to_s

          number && year ? "#{number}/#{year}" : nil

        when :supplement_with_rev
          { supplement: "", supplement_has_revision: true }

        when :supp_year
          value.to_s

        when :edition_year, :edition_month, :edition_day, :edition_has_rev
          return nil if value.nil? || value.to_s.strip.empty?
          value.to_s

        when :edition_letter
          return nil if value.nil? || value.to_s.strip.empty?
          value.to_s

        when :public_draft
          return nil if value.nil?
          value.to_s

        when :update
          handle_update_cast(value)

        when :update_number, :update_year
          return nil if value.nil? || value.to_s.strip.empty?
          value.to_s

        when :addendum
          handle_addendum_cast(value)

        when :addendum_number
          return nil if value.nil? || value.to_s.strip.empty?
          value.to_s

        when :supplement_suffix
          value.to_s

        else
          # Unknown types are ignored (returning nil)
          nil
        end
      end

      # Handle supplement casting with all its variants
      def handle_supplement_cast(value)
        return nil unless value

        if value.is_a?(Array) && value.empty?
          # Empty array means "supp" was present but no suffix
          ""
        else
          str_value = value.to_s.strip
          str_value.empty? ? nil : str_value
        end
      end

      # Handle update casting (number and year)
      def handle_update_cast(value)
        if value.is_a?(Hash)
          {
            update_number: value[:update_number]&.to_s,
            update_year: value[:update_year]&.to_s
          }.compact
        else
          str_value = value.to_s.strip
          str_value.empty? ? nil : str_value
        end
      end

      # Handle addendum casting (number)
      def handle_addendum_cast(value)
        if value.is_a?(Hash)
          addendum_num = value[:addendum_number]&.to_s&.strip
          if addendum_num && !addendum_num.empty?
            { addendum_number: addendum_num }
          else
            { addendum: "true" }
          end
        else
          str_value = value.to_s.strip
          if str_value.empty?
            { addendum: "true" }
          else
            { addendum_number: str_value }
          end
        end
      end
    end
  end
end