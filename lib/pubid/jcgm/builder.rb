# frozen_string_literal: true

module Pubid
  module Jcgm
    class Builder < Pubid::Builder::Base
      def locate_identifier_klass(parsed_hash)
        if parsed_hash[:base]
          type_with_stage = parsed_hash[:type_with_stage]
          return Jcgm.locate_type(:amendment) unless type_with_stage

          return Jcgm.locate_type(locate_typed_stage(type_with_stage).type_code)
        end

        if parsed_hash[:gum_number]
          return Jcgm.locate_type(:gum_guide)
        end

        # Standard guide (no type_with_stage, no gum_number).
        # Don't use locate_stage("") — Guide and GumGuide both have
        # abbr: [""], so the result depends on constant iteration order.
        return Jcgm.locate_type(:guide) unless parsed_hash[:type_with_stage]

        typed_stage = locate_typed_stage(parsed_hash[:type_with_stage])
        Jcgm.locate_type(typed_stage.type_code)
      end

      # The bound grammar flattens the old `(base as base)` wrapper (the
      # bindings cannot nest): the base document keeps the canonical
      # number/date captures and the supplement layer captures
      # supp_number/supp_date. Rebuild the nested shape the builder has
      # always consumed — the base fields rename under :base and the
      # supplement layer takes type_with_stage plus its own
      # supp_number/supp_date, which is exactly the tree the
      # amendment/corrigendum rules produced before the flatten.
      SUPPLEMENT_STAGES = %w[Amd Cor Corrigendum].freeze

      def build(parsed_hash)
        parsed_hash = unflatten_supplement(parsed_hash)
        klass = locate_identifier_klass(parsed_hash)

        # GUM guides store their part number in the shared `number` attribute
        # ("JCGM GUM-6" -> number "6"); the parser tags it :gum_number only to
        # pick this class. Fold it back onto :number before assigning.
        if parsed_hash[:gum_number] && klass == Identifiers::GumGuide
          parsed_hash = parsed_hash.merge(number: parsed_hash[:gum_number])
          parsed_hash.delete(:gum_number)
        end

        identifier = klass.new
        assign_attributes(identifier, parsed_hash)

        # Bare guides/gum-guides carry no parsed stage; derive the (single,
        # published) typed_stage from the concrete class so parse and from_hash
        # agree. Avoids the ambiguous locate_stage("") lookup (Guide and
        # GumGuide both register abbr: [""]).
        if identifier.class.attributes.key?(:typed_stage) && identifier.typed_stage.nil?
          identifier.typed_stage = identifier.class.published_typed_stage ||
            raise(ArgumentError, "No published typed_stage for #{identifier.class}")
        end

        identifier
      end

      private

      def unflatten_supplement(parsed_hash)
        stage = parsed_hash[:type_with_stage]
        return parsed_hash if parsed_hash[:base] || stage.nil? ||
          !SUPPLEMENT_STAGES.include?(stage)

        base_hash = {}
        %i[publisher number gum_number date languages].each do |key|
          base_hash[key] = parsed_hash.delete(key) if parsed_hash[key]
        end
        stage = parsed_hash.delete(:type_with_stage)
        supplement_hash = { type_with_stage: stage }
        if parsed_hash[:supp_number]
          supplement_hash[:number] = parsed_hash.delete(:supp_number)
        end
        if parsed_hash[:supp_date]
          supplement_hash[:date] = parsed_hash.delete(:supp_date)
        end
        # Keep the base as a raw hash: the shared assign_attributes loop
        # routes :base through cast, which recursively builds it — the
        # same path the tree backend's nested subtree took.
        supplement_hash[:base] = base_hash
        parsed_hash.merge(supplement_hash)
      end

      def default_identifier_class
        Identifiers::Guide
      end

      def locate_typed_stage(typed_stage_string)
        typed_stage_string = "" if typed_stage_string.nil?
        Jcgm.locate_stage(typed_stage_string) ||
          raise(ArgumentError, "Unknown type abbreviation: '#{typed_stage_string}'")
      end

      def cast(type, value)
        case type
        when :base
          build(value)
        when :publisher
          Jcgm::Components::Publisher.new(publisher: value.to_s)
        when :number
          value.to_s
        when :date
          date_str = value.to_s
          if date_str.include?("-")
            parts = date_str.split("-")
            Pubid::Components::Date.new(
              year: parts[0],
              month: parts[1],
              day: parts[2],
            )
          else
            Pubid::Components::Date.new(year: date_str)
          end
        when :type_with_stage
          typed_stage = locate_typed_stage(value.to_s)
          {
            stage: typed_stage.to_stage,
            type: typed_stage.to_type,
            typed_stage: typed_stage,
          }
        when :languages
          original_value = value.to_s
          langs = original_value.include?("/") ? original_value.split("/") : [original_value]
          langs.map do |lang|
            lang = lang.strip
            original_lang = lang
            lang = LANG_CHAR_MAP[lang] if lang.length == 1
            Pubid::Components::Language.new(code: lang,
                                            original_code: original_lang)
          end
        end
      end
    end
  end
end

Pubid::Jcgm::Builder.prepend(Pubid::Builder::AllPartsWrap)
