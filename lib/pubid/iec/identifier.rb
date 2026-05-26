require_relative "../identifier"
# frozen_string_literal: true
require_relative "../components/typed_stage"
require_relative "../components/factory"

module Pubid
  module Iec
    class Identifier < ::Pubid::Identifier
      def self.parse(string)
        # Apply legacy update_codes normalization first, before any other preprocessing
        normalized = Core::UpdateCodes.apply(string, :iec)
        parsed = Pubid::Iec::Parser.new.parse(normalized)
        if parsed.nil? || parsed.empty?
          raise Pubid::Iec::Parser::ParseError,
                "Invalid identifier format"
        end

        Pubid::Iec::Builder.new(Pubid::Iec::Scheme).build(parsed)
      end

      # Factory mirroring pubid 1.x's `Pubid::Iec::Identifier.create` API.
      # See {Pubid::Iso::Identifier.create} for the shared design; IEC uses
      # the base `Pubid::Components::*` types via {Pubid::Components::Factory}
      # because IEC's Identifiers inherit the base attribute types.
      def self.create(type: nil, stage: nil, **opts)
        klass = resolve_create_class(type: type, stage: stage)
        attrs = ::Pubid::Components::Factory.from_hash(opts)
        ts = resolve_create_typed_stage(klass, stage)
        attrs[:typed_stage] = ts if ts
        klass.new(**attrs)
      end

      def self.resolve_create_class(type:, stage:)
        klass = nil
        if type
          klass = safe_locate_klass(type)
        elsif stage
          ts = safe_locate_typed_stage(stage)
          klass = safe_locate_klass(ts.type_code) if ts
        end
        return klass if klass && !supplement_klass?(klass)

        if klass
          # TODO(create-shim): supplement identifiers (Amendment, Corrigendum,
          # FragmentIdentifier) require a base_identifier. Wire `base:` kwarg
          # through once a caller needs it.
          raise ArgumentError, "#{klass} requires a base_identifier; " \
                               "Identifier.create cannot build supplements yet"
        end
        Identifiers::InternationalStandard
      end

      # IEC Scheme raises ArgumentError on miss instead of returning nil;
      # wrap so the same control flow works as in the ISO factory.
      def self.safe_locate_klass(type)
        Scheme.locate_identifier_klass_by_type_code(type)
      rescue ArgumentError
        nil
      end

      def self.safe_locate_typed_stage(abbr)
        Scheme.locate_typed_stage_by_abbr(abbr.to_s)
      rescue ArgumentError
        nil
      end

      def self.supplement_klass?(klass)
        Array(Scheme.supplement_identifiers).include?(klass)
      end

      def self.resolve_create_typed_stage(klass, stage)
        if stage
          safe_locate_typed_stage(stage)
        elsif klass.const_defined?(:TYPED_STAGES)
          klass.const_get(:TYPED_STAGES).find do |ts|
            ts.stage_code.to_sym == :published
          end
        end
      end
      private_class_method :resolve_create_class, :safe_locate_klass,
                           :safe_locate_typed_stage, :supplement_klass?,
                           :resolve_create_typed_stage
    end
  end
end
