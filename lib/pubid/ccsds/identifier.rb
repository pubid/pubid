# frozen_string_literal: true

module Pubid
  module Ccsds
    module Identifier
      def self.parse(identifier)
        # Apply legacy update_codes normalization first
        normalized = Core::UpdateCodes.apply(identifier, :ccsds)
        parsed = Pubid::Ccsds::Parser.parse(normalized)
        Pubid::Ccsds::Builder.build(parsed)
      rescue Parslet::ParseFailed => e
        raise "Failed to parse CCSDS identifier '#{identifier}': #{e.message}"
      end

      # Factory that builds a CCSDS identifier from a hash of primitives.
      #
      # Accepts the field shape used by relaton-data-ccsds index entries:
      # `:publisher`, `:number`, `:series`, `:part`, `:book_color`,
      # `:retired`, `:edition`, plus the parsed-shape fields `:type`,
      # `:suffix`, `:language`. CCSDS 2.x maps these as:
      #
      #   * `:series` + `:number`  → combined number ("A" + "20" → "A20")
      #   * `:book_color`          → `:type`            (B/G/M/R/Y/O)
      #   * `:publisher`           → ignored (hardcoded "CCSDS")
      #   * `:retired`             → ignored (no 2.x field)
      #
      # Supplement subclasses (currently just Corrigendum, via `type: :cor`)
      # raise ArgumentError until `base:` kwarg is wired through.
      def self.create(type: nil, **opts)
        if type
          type_sym = type.to_sym
          base_type_key = Identifiers::Base.type[:key].to_sym

          if type_sym != base_type_key
            supplement = supplement_klass_for(type_sym)
            if supplement
              # TODO(create-shim): supplement subclasses (Corrigendum)
              # require a base_identifier. Wire `base:` kwarg through once
              # a caller needs it.
              raise ArgumentError, "#{supplement} requires a " \
                                   "base_identifier; Identifier.create " \
                                   "cannot build supplements yet"
            end

            # Not a class-dispatch key — treat as book_color data
            # (e.g. `type: "G"` for Green Book) and merge back into opts.
            opts = opts.merge(type: type)
          end
        end

        Identifiers::Base.new(**coerce_create_attrs(opts))
      end

      def self.supplement_klass_for(type_sym)
        Scheme.supplement_identifiers.find do |k|
          k.type[:key].to_sym == type_sym
        end
      end

      def self.coerce_create_attrs(opts)
        attrs = {}

        if opts[:number]
          num = opts[:number].to_s
          attrs[:number] =
            opts[:series] ? "#{opts[:series]}#{num}" : num
        end

        attrs[:type] = opts[:book_color].to_s if opts[:book_color]
        # Allow caller to pass :type as data when no :book_color given
        # (parsed identifiers expose it via Base#type attribute).
        attrs[:type] = opts[:type].to_s if opts[:type] && !attrs[:type]

        %i[part edition suffix language].each do |k|
          v = opts[k]
          attrs[k] = v.to_s unless v.nil?
        end

        attrs
      end
      private_class_method :supplement_klass_for, :coerce_create_attrs
    end
  end
end
