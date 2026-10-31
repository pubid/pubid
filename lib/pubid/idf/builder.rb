# frozen_string_literal: true

module Pubid
  module Idf
    class Builder < Pubid::Builder::Base
      LANG_CHAR_MAP = {
        "R" => "ru",
        "F" => "fr",
        "E" => "en",
        "A" => "ar",
        "S" => "es",
        "D" => "de",
      }.freeze

      def build(parsed_hash)
        parsed_hash = split_supplement_base(parsed_hash)
        # The Parslet tree carried a zero-width type_with_stage (an empty
        # capture when no type is spelled) whose cast drove the default
        # stage; the artifact tree omits the key entirely — restore the
        # default input.
        parsed_hash[:type_with_stage] ||= ""
        all_parts = parsed_hash.delete(:all_parts)
        typed_stage = Pubid::Idf.locate_stage(parsed_hash[:type_with_stage])
        identifier = Pubid::Idf.locate_type(typed_stage.type_code).new

        if type_with_stage_fr = parsed_hash.delete(:type_with_stage_fr)
          parsed_hash[:type_with_stage] = type_with_stage_fr
        end

        assign_attributes(identifier, parsed_hash)
        # The locate-stage pass above selects the class; the typed_stage
        # attribute itself is set by the :type_with_stage key. Subtrees
        # built without that key (e.g. a joint identifier from a PG
        # artifact shape) would render with a nil typed_stage otherwise.
        identifier.typed_stage ||= typed_stage if typed_stage
        # "(all parts)" names every part of the document, so it wraps the
        # document, which holds no mark itself.
        all_parts ? identifier.to_all_parts : identifier
      end

      # The bound grammar flattens the supplement's base wrapper (the
      # bindings cannot nest): the supplement layer keeps the canonical
      # number_with_part/date/type_with_stage captures and the base
      # portion captures under base_* names. Rebuild the nested shape
      # the builder has always consumed — the base_* keys rename onto
      # their canonical counterparts and the shared publisher capture
      # belongs to the base (the tree backend captured it inside the
      # base subtree, so the supplement itself carries no publisher).
      BASE_KEY_MAP = {
        base_number_with_part: :number_with_part,
        base_date: :date,
        base_type_with_stage: :type_with_stage,
        base_stage_iteration: :stage_iteration,
      }.freeze

      private

      def split_supplement_base(parsed_hash)
        unless BASE_KEY_MAP.keys.any? { |k| parsed_hash.key?(k) }
          return parsed_hash
        end

        base_hash = {}
        BASE_KEY_MAP.each do |bound_key, tree_key|
          next unless parsed_hash.key?(bound_key)

          base_hash[tree_key] = parsed_hash.delete(bound_key)
        end
        if parsed_hash[:publisher]
          base_hash[:publisher] = parsed_hash.delete(:publisher)
        end
        # Keep the base as a raw hash: the shared assign_attributes loop
        # routes :base through cast, which recursively builds it — the
        # same path the tree backend's nested subtree took.
        parsed_hash[:base] = base_hash
        parsed_hash
      end

      def default_identifier_class
        Identifiers::InternationalStandard
      end

      def cast(type, value)
        case type
        when :base
          build(value)
        when :publisher
          Components::Publisher.new(body: value)
        when :number_with_part
          parts = value.to_s.split("-")
          number = parts.shift
          part = parts.shift
          subpart = parts.size.positive? ? parts.join("-") : nil
          code_hash = { number: number }
          code_hash[:part] = part if part
          code_hash[:subpart] = subpart if subpart
          code_hash
        when :type_with_stage
          iteration = value.to_s.match(/(\d+)$/)
          value = value.to_s.sub(iteration.to_s, "")
          typed_stage = Pubid::Idf.locate_stage(value || "")
          {
            stage: typed_stage.to_stage,
            type: typed_stage.to_type,
            typed_stage: typed_stage,
          }
        when :date
          value = value.to_s
          if value.match?(/^\d{4}(-\d{2})?$/)
            year, month = value.split("-")
            Components::Date.new(year: year, month: month || nil)
          elsif value.is_a?(Integer) || (value.is_a?(String) && value.match?(/^\d{4}$/))
            Components::Date.new(year: value)
          else
            raise ArgumentError, "Invalid date format: #{value.inspect}"
          end
        when :languages
          value = value.to_s.gsub("/", ",")
          value.split(",").map do |lang|
            lang = lang.strip
            lang = LANG_CHAR_MAP[lang] if lang.length == 1
            Components::Language.new(code: lang)
          end
        when :all_parts
          Components::Locality.new(all_parts: true)
        else
          raise ArgumentError, "Unknown type: #{type}"
        end
      end
    end
  end
end

Pubid::Idf::Builder.prepend(Pubid::Builder::AllPartsWrap)
