# frozen_string_literal: true

require_relative "../components/factory"

module Pubid
  module CenCenelec
    module Identifier
      def self.parse(identifier)
        scheme = Scheme.new
        parsed = Parser.parse(identifier)
        Builder.new(scheme).build(parsed)
      rescue Parslet::ParseFailed => e
        raise "Failed to parse CEN identifier '#{identifier}': #{e.message}"
      end

      # Factory mirroring pubid 1.x's `Pubid::Cen::Identifier.create` API.
      # Dispatches via {Pubid::CenCenelec::Scheme}'s IDENTIFIER_CLASS_MAP
      # and TYPED_STAGES_REGISTRY. Default is EuropeanNorm.
      def self.create(type: nil, stage: nil, **opts)
        klass = resolve_create_class(type: type, stage: stage)
        attrs = ::Pubid::Components::Factory.from_hash(opts)
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
        klass || Identifiers::EuropeanNorm
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
      private_class_method :resolve_create_class,
                           :resolve_create_typed_stage
    end
  end
end
