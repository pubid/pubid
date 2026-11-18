# frozen_string_literal: true

module Pubid
  module Eu
    # Bound captures (data/parg/eu.json) → an EU identifier.
    #
    # CELEX and ELI give the year and the number by position. The canonical
    # and the long forms give two numbers, +first+ and +second+, and the
    # order is not in the grammar: `Regulation (EC) No 2003/2003` exists, and
    # a pre-2015 number can look like a year. See .number_first_for.
    class Builder
      TYPES_BY_WORD = {
        "Regulation" => :Regulation,
        "Directive" => :Directive,
        "Decision" => :Decision,
      }.freeze
      TYPES_BY_CELEX = {
        "R" => :Regulation, "L" => :Directive, "D" => :Decision
      }.freeze
      TYPES_BY_ELI = {
        "reg" => :Regulation, "dir" => :Directive, "dec" => :Decision
      }.freeze

      # The first Official Journal acts (ECSC) date from 1952.
      YEARS = (1952..2099)

      # One parsed act before it becomes an identifier.
      Act = Struct.new(:klass, :year, :number, :number_first)

      def self.build(data, input = nil)
        new(input).build(data)
      end

      def initialize(input)
        @input = input
      end

      # Which of two printed numbers is the year, when the input has no
      # "No". Only one plausible year: that one. Both: a first value from
      # 2015 is the year (every act prints <year>/<number> from 2015);
      # otherwise a regulation prints <number>/<year> and other acts
      # <year>/<number>. Neither: nil. The renderer calls this too, to know
      # when a plain print would read back as another act.
      def self.number_first_for(klass, first, second)
        first_year = year?(first)
        second_year = year?(second)
        return nil unless first_year || second_year
        return !first_year if first_year != second_year
        return false if first.to_i >= Identifier::FIXED_ORDER_YEAR

        klass == :Regulation
      end

      def self.year?(value)
        value.length == 4 && YEARS.cover?(value.to_i)
      end

      def build(data)
        act = positional(data) || from_pair(data)
        fail!("#{act.year} is not a year") unless self.class.year?(act.year)
        number = strip_zeros(act.number)
        fail!("number 0") if number == "0"

        id = Identifiers.const_get(act.klass).new(
          number: number,
          date: ::Pubid::Components::Date.new(year: act.year),
          family: family(data),
        )
        keep_order(id, act.number_first)
      end

      private

      # CELEX and ELI: the year and the number have fixed places.
      def positional(data)
        klass = if data[:celex_letter]
                  TYPES_BY_CELEX.fetch(data[:celex_letter])
                elsif data[:eli_type]
                  TYPES_BY_ELI.fetch(data[:eli_type])
                end
        klass && Act.new(klass, data[:year], data[:number], nil)
      end

      def from_pair(data)
        klass = TYPES_BY_WORD.fetch(data[:type_word])
        first = data[:first]
        second = data[:second]
        # "No" marks <number>/<year> (Regulation (EU) No 1227/2011,
        # Decision No 1082/2013/EU); every other pair reads by the rule.
        number_first = !data[:no].nil? ||
          self.class.number_first_for(klass, first, second)
        fail!("no year in #{first}/#{second}") if number_first.nil?

        year, number = number_first ? [second, first] : [first, second]
        Act.new(klass, year, number, number_first)
      end

      # Keep the order only when it is not what the render rule prints.
      def keep_order(id, number_first)
        unless number_first.nil? || number_first == id.default_number_first?
          id.number_first = number_first
        end
        id
      end

      def family(data)
        bracket = data[:family]
        suffix = data[:family_suffix]
        if bracket && suffix && bracket != suffix
          fail!("two families, #{bracket} and #{suffix}")
        end

        bracket || suffix
      end

      def strip_zeros(number)
        number.sub(/\A0+(?=\d)/, "")
      end

      def fail!(message)
        raise Pubid::Errors::ParseError.new(
          "EU legal act: #{message}", nil, input: @input, flavor: "eu"
        )
      end
    end
  end
end

Pubid::Eu::Builder.prepend(Pubid::Builder::AllPartsWrap)
