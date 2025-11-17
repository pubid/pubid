require_relative "../components/publisher"
require_relative "../components/code"
require_relative "../components/date"
require_relative "../bundled_identifier"

module PubidNew
  module Cen
    class Builder
      def initialize(scheme)
        @scheme = scheme
        self
      end

      def locate_typed_stage(typed_stage_string)
        # Handle Hash input (when Parslet returns a hash)
        if typed_stage_string.is_a?(Hash)
          # Extract nested stage value
          if typed_stage_string[:stage]
            stage_val = typed_stage_string[:stage].to_s
            # Combine with EN: pr + EN = prEN
            typed_stage_string = "#{stage_val}EN"
          else
            typed_stage_string = typed_stage_string[:type_with_stage] || "EN"
          end
        end
        
        # Default to EN if no type specified
        typed_stage_string = "EN" if typed_stage_string.nil? || typed_stage_string.to_s.empty?
        
        type_str = typed_stage_string.to_s
        
        # If it's a bare stage like "pr" or "Fpr", combine with EN
        if %w[pr Fpr].include?(type_str)
          type_str = "#{type_str}EN"
        end

        @scheme.locate_typed_stage_by_abbr(type_str)
      end

      def locate_identifier_klass(parsed_hash)
        # Check for bundled identifier first
        return BundledIdentifier if parsed_hash[:base_document] && parsed_hash[:supplements]

        # Check if it's a supplement
        if parsed_hash[:base_identifier]
          typed_stage = locate_typed_stage(parsed_hash[:type_with_stage])
          return @scheme.locate_identifier_klass_by_type_code(typed_stage.type_code)
        end

        # Regular identifier - check type_with_stage or stage
        type_str = if parsed_hash[:type_with_stage]
          parsed_hash[:type_with_stage]
        elsif parsed_hash[:stage]
          # prEN or FprEN case
          "#{parsed_hash[:stage]}EN"
        else
          nil
        end
        
        typed_stage = locate_typed_stage(type_str)
        @scheme.locate_identifier_klass_by_type_code(typed_stage.type_code)
      end

      def build(parsed_hash)
        identifier = locate_identifier_klass(parsed_hash).new

        # Handle bundled identifiers specially
        if identifier.is_a?(BundledIdentifier)
          return build_bundled_identifier(parsed_hash)
        end

        parsed_hash.each_pair do |key, value|
          realized_components = cast(key.to_sym, value)

          next if realized_components.nil?

          # Map supplement_number to number for supplements
          mapped_key = (key == :supplement_number) ? :number : key

          case realized_components
          when Hash
            realized_components.each_pair do |sub_key, sub_value|
              identifier.send("#{sub_key}=", sub_value) if identifier.respond_to?("#{sub_key}=")
            end
          else
            identifier.send("#{mapped_key}=", realized_components) if identifier.respond_to?("#{mapped_key}=")
          end
        end

        identifier
      end

      def build_bundled_identifier(parsed_hash)
        base_doc = build(parsed_hash[:base_document])
        supplements = parsed_hash[:supplements].map do |sup_hash|
          sup_data = sup_hash[:supplement]
          
          # Determine the supplement class
          typed_stage = locate_typed_stage(sup_data[:type_with_stage])
          sup_klass = @scheme.locate_identifier_klass_by_type_code(typed_stage.type_code)
          
          # Build the supplement with minimal data
          sup = sup_klass.new
          sup.typed_stage = typed_stage
          sup.type = typed_stage.to_type
          sup.stage = typed_stage.to_stage
          sup.number = Components::Code.new(value: sup_data[:supplement_number]) if sup_data[:supplement_number]
          sup.date = cast(:date, sup_data[:date]) if sup_data[:date]
          
          sup
        end

        BundledIdentifier.new(
          base_document: base_doc,
          supplements: supplements
        )
      end

      def cast(type, value)
        case type
        when :base_identifier, :base_document
          build(value)

        when :publisher
          Components::Publisher.new(body: value)

        when :copublishers
          if value.nil? || value.empty?
            nil
          else
            value.map do |copublisher|
              Components::Publisher.new(body: copublisher[:copublisher])
            end
          end

        when :number_with_part
          # "10077" (no part)
          # or "10077-1" ('1' is part)
          # or "29110-5-1-1" ('5' is part, '1-1' is subpart)

          normalized_value = value.to_s.tr(Parser::DASH_CHARS.join, "-")
          parts = normalized_value.split("-")
          number = parts.shift
          part = parts.shift
          subpart = parts.any? ? parts.join("-") : nil

          code_hash = { number: Components::Code.new(value: number) }
          code_hash[:part] = Components::Code.new(value: part) if part
          code_hash[:subpart] = Components::Code.new(value: subpart) if subpart

          code_hash

        when :supplement_number
          Components::Code.new(value: value)

        when :type_with_stage
          # "TS", "TR", "CWA", "HD", "Guide", "prEN", "FprEN"
          # Or nested hash: {:stage=>"pr"}
          
          # Extract string value from nested hash if present
          if value.is_a?(Hash) && value[:stage]
            value_str = "#{value[:stage]}EN"
          else
            value_str = value.to_s
          end
          
          # Special case: CWA and HD act as both publisher and type
          if %w[CWA HD].include?(value_str)
            typed_stage = locate_typed_stage(value_str)
            return {
              publisher: Components::Publisher.new(body: value_str),
              stage: typed_stage.to_stage,
              type: typed_stage.to_type,
              typed_stage: typed_stage,
            }
          end
          
          typed_stage = locate_typed_stage(value_str.empty? ? "EN" : value_str)

          {
            stage: typed_stage.to_stage,
            type: typed_stage.to_type,
            typed_stage: typed_stage,
          }

        when :stage
          # "pr" or "Fpr" from stage_prefix
          # Don't process separately - it will be combined with type_with_stage
          nil

        when :date
          value = value.to_s
          if value.match?(/^\d{4}(-\d{2})?(-\d{2})?$/)
            parts = value.split("-")
            Components::Date.new(
              year: parts[0],
              month: parts[1] || nil,
              day: parts[2] || nil
            )
          elsif value.match?(/^\d{4}$/)
            Components::Date.new(year: value)
          else
            raise ArgumentError, "Invalid date format: #{value.inspect}"
          end

        else
          # Don't process unknown keys
          nil
        end
      end
    end
  end
end