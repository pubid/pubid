# frozen_string_literal: true

module Pubid
  module Astm
    class Identifier < Pubid::Identifier
      def self.parse(str)
        parser = Parser.new
        builder = Builder.new

        parsed = parser.parse(str)
        builder.build(parsed)
      end

      # Factory that builds an ASTM identifier from a hash of primitives.
      # Default is {Identifiers::Standard}.
      #
      # ASTM's Code Component has :letter (single letter A–Z) + :number
      # (rest); `.create` accepts either an already-split pair or a
      # combined `:code` string which it splits at the first digit.
      TYPE_KEY_TO_KLASS = {
        standard:           "Standard",
        adjunct:            "Adjunct",
        manual:             "Manual",
        monograph:          "Monograph",
        research_report:    "ResearchReport",
        technical_report:   "TechnicalReport",
        data_series:        "DataSeries",
        iso_dual_published: "IsoDualPublished",
        work_in_progress:   "WorkInProgress",
      }.freeze

      def self.create(type: nil, **opts)
        klass = resolve_create_class(type)
        klass.new(**coerce_create_attrs(opts, klass: klass))
      end

      def self.resolve_create_class(type)
        return Identifiers::Standard if type.nil?

        klass_name = TYPE_KEY_TO_KLASS[type.to_sym]
        raise ArgumentError, "Unknown ASTM type: #{type.inspect}" unless klass_name

        Identifiers.const_get(klass_name)
      end

      def self.coerce_create_attrs(opts, klass:)
        attrs = { publisher: (opts[:publisher] || "ASTM").to_s }

        if opts[:letter] || opts[:number]
          attrs[:code] = Pubid::Astm::Components::Code.new(
            letter:    opts[:letter]&.to_s,
            number:    opts[:number]&.to_s,
            suffix:    opts[:suffix]&.to_s,
            subseries: opts[:subseries]&.to_s,
            dual_m:    opts[:dual_m],
          )
        elsif (combined = opts[:code])
          letter, number = split_astm_code(combined.to_s)
          attrs[:code] = Pubid::Astm::Components::Code.new(
            letter: letter, number: number,
          )
        end

        attrs[:year] = opts[:year].to_s if opts[:year]
        attrs[:format_suffix] = opts[:format_suffix].to_s if opts[:format_suffix]

        # Pass through subclass-specific kwargs (designation, edition,
        # committee, …) when the class declares them.
        opts.each do |k, v|
          next if attrs.key?(k)
          next if %i[publisher code letter number suffix subseries
                     dual_m year format_suffix].include?(k)
          attrs[k] = v if klass.attributes.key?(k)
        end
        attrs
      end

      # ASTM codes use a single letter prefix (A–Z) followed by digits.
      # "A36" → ["A", "36"]; "E1444" → ["E", "1444"]. Codes without a
      # leading letter (data series numbers, etc.) pass through with
      # letter: nil.
      def self.split_astm_code(str)
        match = str.match(/\A([A-Za-z])(\d.*)\z/)
        return match.captures if match

        [nil, str]
      end
      private_class_method :resolve_create_class, :coerce_create_attrs,
                           :split_astm_code
    end
  end
end
