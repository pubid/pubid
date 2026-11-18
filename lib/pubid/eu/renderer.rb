# frozen_string_literal: true

module Pubid
  module Eu
    # The canonical form: "EU <Type> <a>/<b>", the order from
    # Identifier#number_first?.
    #
    # Two acts can share one plain print: 32015R2014 and 32014R2015 both give
    # "2015/2014". The parser reads the plain pair by
    # Builder.number_first_for, so when that reading is not this act, the
    # renderer prints "No <number>/<year>" instead — "No" always marks
    # <number>/<year>, so every print parses back to the act that made it.
    class Renderer < ::Pubid::Renderers::Base
      def render(**_opts)
        "#{Identifier::PUBLISHER} #{@id.class.type[:title]} #{numbers}"
      end

      private

      def numbers
        number = @id.number
        year = @id.year
        return number.to_s if year.nil?

        number_first = @id.number_first?
        pair = number_first ? [number, year] : [year, number]
        return pair.join("/") if reads_back?(pair, number_first)

        "No #{number}/#{year}"
      end

      def reads_back?(pair, number_first)
        klass = @id.class.name.split("::").last.to_sym
        Builder.number_first_for(klass, *pair) == number_first
      end
    end
  end
end
