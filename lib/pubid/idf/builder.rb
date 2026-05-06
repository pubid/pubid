# frozen_string_literal: true

module Pubid
  # Identifier that
  module Idf
    class Builder
      LANG_CHAR_MAP = {
        "R" => "ru",
        "F" => "fr",
        "E" => "en",
        "A" => "ar",
        "S" => "es",
        "D" => "de",
      }.freeze

      def initialize
        # Builder uses Idf::Scheme class methods (class << self pattern)
      end

      def build(parsed_hash)
        # Check the `:type_with_stage` to determine the identifier class
        # :type_with_stage will be nil if it is an IS.
        typed_stage = Scheme.locate_typed_stage_by_abbr(parsed_hash[:type_with_stage])

        # Instantiate the identifier based on the typed stage
        identifier = Scheme.locate_identifier_klass_by_type_code(typed_stage.type_code).new

        # For French GUIDE entries: "Guide ISO/CEI 37:1995"
        if type_with_stage_fr = parsed_hash.delete(:type_with_stage_fr)
          parsed_hash[:type_with_stage] = type_with_stage_fr
        end

        parsed_hash.each_pair do |key, value|
          realized_components = cast(key.to_sym, value)
          next if realized_components.nil?

          case realized_components
          when Hash
            realized_components.each_pair do |sub_key, sub_value|
              identifier.send("#{sub_key}=", sub_value)
            rescue NoMethodError
              nil
            end
          else
            begin
              identifier.send("#{key}=", realized_components)
            rescue NoMethodError
              nil
            end
          end
        end

        identifier
      end

      def cast(type, value)
        case type
        when :base_identifier
          # If it has a base identifier, we need to build a supplement
          # We assume that the base identifier is already a valid Identifier object
          build(value)

        when :publisher
          Components::Publisher.new(body: value)

        when :number_with_part
          # "1234" or "1234-1" or "1234-1-2"
          # or "29110-5-1-1"

          # Split the number into parts
          parts = value.to_s.split("-")
          number = parts.shift # The first part is always the number
          part = parts.shift # The second part is the part, if present
          subpart = parts.size.positive? ? parts.join("-") : nil # The third part is the subpart, if present

          code_hash = { number: Components::Code.new(value: number) }

          if part
            code_hash[:part] = Components::Code.new(value: part)
          end

          if subpart
            code_hash[:subpart] = Components::Code.new(value: subpart)
          end

          code_hash

        when :type_with_stage
          # "WD"
          # "PAS"
          # "CD TR"
          iteration = value.to_s.match(/(\d+)$/)
          value = value.to_s.sub(iteration.to_s, "")
          typed_stage = Scheme.locate_typed_stage_by_abbr(value || "")

          ## IMPORTANT!!
          # Always use TypedStage in an Identifier or separate Type and Stage.
          {
            stage: typed_stage.to_stage,
            type: typed_stage.to_type,
            typed_stage: typed_stage,
          }
        # when :stage_iteration
        #   # "1" or "2"
        #   Components::Code.new(value: value.to_s)

        when :date
          value = value.to_s
          # If there is month, "2005-12"
          if value.match?(/^\d{4}(-\d{2})?$/)
            year, month = value.split("-")
            Components::Date.new(year: year, month: month || nil)
          elsif value.is_a?(Integer) || (value.is_a?(String) && value.match?(/^\d{4}$/))
            # If it's just a year, "2005"
            Components::Date.new(year: value)
          else
            raise ArgumentError, "Invalid date format: #{value.inspect}"
          end

        # when :edition
        #   Components::Edition.new(value: value)

        when :languages
          # Can be: :languages=>"E/F/R" or: :languages=>"en,fr,ru"
          value = value.to_s.gsub("/", ",")

          value.split(",").map do |lang|
            # We need to convert these into 2 char language codes
            lang = lang.strip
            lang = LANG_CHAR_MAP[lang] if lang.length == 1
            Components::Language.new(code: lang)
          end

        when :all_parts
          Components::Locality.new(all_parts: true)

        # # TODO!!
        # # ISO 4214:2022 | IDF/RM 254:2022
        # when :joint_identifier
        #   # If it has a joint identifier, we need to build a supplement
        #   # We assume that the joint identifier is already a valid Identifier object
        #   raise ArgumentError, "Joint identifier type not yet implemented: #{type}"
        else
          raise ArgumentError, "Unknown type: #{type}"
        end
      end
    end
  end
end
