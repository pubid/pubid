# frozen_string_literal: true

module Pubid
  module Jcgm
    class Identifier < ::Pubid::Identifier
      def self.parse(string)
        Pubid::Jcgm.parse(string)
      end

      # Factory mirroring pubid 1.x's `Pubid::Jcgm::Identifier.create` API.
      # Dispatches `:guide` (default) → Guide, `:gum_guide` → GumGuide.
      TYPE_KEY_TO_KLASS = {
        guide:     "Guide",
        gum_guide: "GumGuide",
      }.freeze

      def self.create(type: nil, **opts)
        klass = resolve_create_class(type)
        attrs = coerce_create_attrs(opts)
        ts = klass.const_defined?(:TYPED_STAGES) &&
             klass.const_get(:TYPED_STAGES).find do |t|
               t.stage_code&.to_sym == :published
             end
        attrs[:typed_stage] = ts if ts
        klass.new(**attrs)
      end

      def self.resolve_create_class(type)
        return Identifiers::Guide if type.nil?

        klass_name = TYPE_KEY_TO_KLASS[type.to_sym]
        raise ArgumentError, "Unknown JCGM type: #{type.inspect}" unless klass_name

        Identifiers.const_get(klass_name)
      end

      def self.coerce_create_attrs(opts)
        attrs = {
          publisher: Pubid::Jcgm::Components::Publisher.new(
            publisher: (opts[:publisher] || "JCGM").to_s,
          ),
        }
        if (v = opts[:number])
          attrs[:number] = Pubid::Components::Code.new(value: v.to_s)
        end
        if (v = opts[:year])
          attrs[:date] = Pubid::Components::Date.new(year: v.to_s)
        end
        attrs
      end
      private_class_method :resolve_create_class, :coerce_create_attrs
    end
  end
end
