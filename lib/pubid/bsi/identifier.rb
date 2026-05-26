# frozen_string_literal: true

module Pubid
  module Bsi
    module Identifier
      def self.parse(string)
        # Delegate to IEC for bare IEC identifiers
        # This handles IEC-specific features like VAP suffixes (CSV, RLV, etc.)
        # and consolidated supplements (+AMD1:2001)
        if string.match?(/\bIEC\b/) &&
            (string.match?(/\s+(CSV|CMV|RLV|SER|EXV|PAC|PRV)\b/) ||
             string.match?(/\+AMD\d+:/) ||
             string.match?(/\+COR\d+:/))
          return Pubid::Iec.parse(string)
        end

        parser = Parser.new
        scheme = Scheme.new

        parsed = parser.parse(string)
        Builder.build(parsed, scheme)
      rescue Parslet::ParseFailed => e
        raise StandardError, "Failed to parse '#{string}': #{e.message}"
      end

      # Factory mirroring pubid 1.x's `Pubid::Bsi::Identifier.create` API.
      # Dispatches via {Pubid::Bsi::Scheme}'s IDENTIFIER_CLASS_MAP and
      # TYPED_STAGES_REGISTRY; default subclass is BritishStandard.
      #
      # BSI's renderer requires BSI-namespaced Component subclasses
      # (`Bsi::Components::*`), so coercion is inlined rather than reusing
      # {Pubid::Components::Factory}.
      def self.create(type: nil, stage: nil, **opts)
        klass = resolve_create_class(type: type, stage: stage)
        attrs = coerce_create_attrs(opts)
        ts = resolve_create_typed_stage(klass, stage)
        attrs[:typed_stage] = ts if ts
        klass.new(**attrs)
      end

      def self.resolve_create_class(type:, stage:)
        scheme = Scheme.new
        klass = nil
        if type
          klass = scheme.locate_identifier_klass_by_type_code(type)
        elsif stage
          ts = scheme.locate_typed_stage_by_abbr(stage.to_s)
          klass = scheme.locate_identifier_klass_by_type_code(ts.type_code) if ts
        end
        klass || Identifiers::BritishStandard
      end

      def self.resolve_create_typed_stage(klass, stage)
        if stage
          Scheme.new.locate_typed_stage_by_abbr(stage.to_s)
        elsif klass.const_defined?(:TYPED_STAGES)
          klass.const_get(:TYPED_STAGES).find do |ts|
            ts.stage_code.to_sym == :published
          end
        end
      end

      def self.coerce_create_attrs(opts)
        attrs = {}
        if (v = opts[:publisher])
          attrs[:publisher] = Components::Publisher.new(body: v.to_s)
        end
        %i[number part subpart].each do |k|
          v = opts[k]
          attrs[k] = Components::Code.new(value: v.to_s) unless v.nil?
        end
        if (v = opts[:year])
          attrs[:date] = Components::Date.new(year: v.to_s)
        end
        # BSI :edition is a plain string attribute (not a Component).
        attrs[:edition] = opts[:edition].to_s if opts[:edition]
        # TODO(create-shim): BSI also has prefix, flex_prefix, iteration,
        # second_number, month, translation_lang/upper attributes that
        # aren't yet wired through. Add as call sites require them.
        attrs
      end
      private_class_method :resolve_create_class,
                           :resolve_create_typed_stage,
                           :coerce_create_attrs
    end
  end
end
