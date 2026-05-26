# frozen_string_literal: true

module Pubid
  module Asme
    class Identifier < Pubid::Identifier
      def self.parse(str)
        parser = Parser.new
        builder = Builder.new

        parsed = parser.parse(str)
        builder.build(parsed)
      end

      # Factory that builds an ASME identifier from a hash of primitives.
      # Default is {Identifiers::Standard}. ASME's Code Component has
      # `:designator` (leading letters, e.g. "B") and `:number` (rest,
      # e.g. "16.34"); `.create` accepts either an already-split pair or
      # a combined `:code` string which it splits at the first digit.
      def self.create(**opts)
        Identifiers::Standard.new(**coerce_create_attrs(opts))
      end

      def self.coerce_create_attrs(opts)
        attrs = { publisher: (opts[:publisher] || "ASME").to_s }

        if opts[:designator] || opts[:number]
          attrs[:code] = Pubid::Asme::Components::Code.new(
            designator: opts[:designator]&.to_s,
            number:     opts[:number]&.to_s,
          )
        elsif (combined = opts[:code])
          designator, number = split_asme_code(combined.to_s)
          attrs[:code] = Pubid::Asme::Components::Code.new(
            designator: designator,
            number:     number,
          )
        end

        %i[year reaffirmation language csa_number draft_year
           revision_note parenthetical_revision ptc_suffix
           joint_publisher first_publisher first_code].each do |k|
          attrs[k] = opts[k].to_s unless opts[k].nil?
        end
        attrs[:handbook] = opts[:handbook] if opts.key?(:handbook)
        attrs
      end

      # ASME codes pair a letter designator with a numeric/dotted number.
      # Split at the first digit. "B16.34" → ["B", "16.34"]; "Y14.5" →
      # ["Y", "14.5"]; "BPVC.III.1.NB" → ["BPVC.III.1.NB", nil] (no
      # leading all-letters before the first digit — pass through).
      def self.split_asme_code(str)
        match = str.match(/\A([A-Za-z]+)(\d.*)\z/)
        return match.captures if match

        [str, nil]
      end
      private_class_method :coerce_create_attrs, :split_asme_code
    end
  end
end
