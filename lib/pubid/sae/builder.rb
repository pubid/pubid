# frozen_string_literal: true

module Pubid
  module Sae
    # Builds a Pubid::Sae::Identifier from the grammar's bound captures.
    #
    # The grammar only segments the code (data/parg/sae.json):
    # +type number [dash] [tail] [/part [part_tail]] [_A amendment] [date]+.
    # The meaning of each segment is decided here, because it depends on the
    # family:
    #
    # * +type+ is stored in its printed form (+AMSQQA+ -> +AMS-QQ-A+).
    # * A one-letter +tail+ or +part_tail+ is the revision (+AMS4121J+,
    #   +AS22520/45A+), except the +M+ of a J or JA report, which marks the
    #   metric document (+J174M+) and stays in the number.
    # * A longer tail names another document (+J1939DA+, the digital annex;
    #   +J2735SET+) and stays in the number, so it keeps its own index bucket.
    # * A +dash+ is a USCAR revision (+USCAR2-6+); in every other family it
    #   is part of the number (+J1939-71+, +EIA649-2+).
    class Builder < Pubid::Builder::Base
      def self.build(parsed_data)
        new.build(parsed_data)
      end

      def build(data)
        data = flatten_array(data) if data.is_a?(Array)
        data = data.transform_keys(&:to_sym)
        Identifier.new(**attributes_for(data))
      end

      private

      def default_identifier_class
        Identifier
      end

      def attributes_for(data)
        abbr = Components::Type.canonical(data[:type])
        attrs = { type: Components::Type.new(abbr: abbr),
                  number: data[:number].to_s }
        apply_dash(attrs, abbr, data[:dash])
        apply_tail(attrs, abbr, data[:tail], part: data[:part])
        apply_part(attrs, data[:part], data[:part_tail])
        attrs[:amendment] = data[:amendment].to_s if data[:amendment]
        attrs[:date] = date_for(data) if data[:year]
        attrs
      end

      def apply_dash(attrs, abbr, dash)
        return unless dash

        if Components::Type::DASH_REVISION.include?(abbr)
          attrs[:revision] = dash.to_s
        else
          attrs[:number] += "-#{dash}"
        end
      end

      # A one-letter tail before a part (AMS4121J/2) or after a USCAR dash
      # revision (USCAR2-6A) has no place in the model: no SAE code has that
      # shape, and storing it in `number` would split the index bucket and
      # print a string that does not parse back. Such input is refused.
      def apply_tail(attrs, abbr, tail, part:)
        return unless tail

        tail = tail.to_s
        if !revision_letter?(abbr, tail)
          attrs[:number] += tail
        elsif part || attrs[:revision]
          refuse("a revision letter #{tail} before a part or after a " \
                 "dash revision")
        else
          attrs[:revision] = tail
        end
      end

      def apply_part(attrs, part, part_tail)
        return unless part

        attrs[:part] = part.to_s
        return unless part_tail

        if part_tail.to_s.length == 1
          attrs[:revision] = part_tail.to_s
        else
          attrs[:part] += part_tail.to_s
        end
      end

      def revision_letter?(abbr, tail)
        return false unless tail.length == 1

        !(tail == "M" && Components::Type::METRIC_SUFFIX.include?(abbr))
      end

      def date_for(data)
        month = data[:month]&.to_i
        refuse("month #{data[:month]}") if month && !(1..12).cover?(month)

        Components::Date.new(year: data[:year].to_i, month: month)
      end

      def refuse(what)
        raise Pubid::Errors::ParseError.new(
          "SAE identifier with #{what} is not supported", nil, flavor: "sae"
        )
      end
    end
  end
end

Pubid::Sae::Builder.prepend(Pubid::Builder::AllPartsWrap)
