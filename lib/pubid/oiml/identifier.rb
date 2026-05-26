# frozen_string_literal: true

module Pubid
  module Oiml
    class Identifier < Pubid::Identifier
      def to_urn
        UrnGenerator.new(self).generate
      end

      # Factory mirroring pubid 1.x's `Pubid::Oiml::Identifier.create` API.
      # Default subclass is {Identifiers::Recommendation}.
      TYPE_KEY_TO_KLASS = {
        recommendation:    "Recommendation",
        document:          "Document",
        guide:             "Guide",
        vocabulary:        "Vocabulary",
        basic_publication: "BasicPublication",
        expert_report:     "ExpertReport",
        seminar_report:    "SeminarReport",
        annex:             "Annex",
      }.freeze

      def self.create(type: nil, **opts)
        klass = resolve_create_class(type)
        klass.new(**coerce_create_attrs(opts))
      end

      def self.resolve_create_class(type)
        return Identifiers::Recommendation if type.nil?

        klass_name = TYPE_KEY_TO_KLASS[type.to_sym]
        raise ArgumentError, "Unknown OIML type: #{type.inspect}" unless klass_name

        Identifiers.const_get(klass_name)
      end

      def self.coerce_create_attrs(opts)
        attrs = { publisher: (opts[:publisher] || "OIML").to_s }

        if opts[:code].is_a?(Pubid::Oiml::Components::Code)
          attrs[:code] = opts[:code]
        elsif opts[:code] || opts[:number]
          attrs[:code] = Pubid::Oiml::Components::Code.new(
            number:  (opts[:number] || opts[:code])&.to_s,
            part:    opts[:part]&.to_s,
            subpart: opts[:subpart]&.to_s,
          )
        end

        if (v = opts[:year])
          attrs[:date] = Pubid::Components::Date.new(year: v.to_s)
        end
        %i[stage iteration language edition].each do |k|
          attrs[k] = opts[k].to_s unless opts[k].nil?
        end
        attrs
      end
      private_class_method :resolve_create_class, :coerce_create_attrs
    end
  end
end
