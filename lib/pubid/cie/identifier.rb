# frozen_string_literal: true

module Pubid
  module Cie
    # Base Identifier class for CIE
    # Provides parse() entry point
    class Identifier < Lutaml::Model::Serializable
      attribute :style, :string # "legacy" or "current"

      # Parse CIE identifier string
      def self.parse(input)
        parsed = Parser.parse(input)
        builder = Builder.new
        builder.build(parsed, original_string: input)
      end

      # Factory that builds a CIE identifier from a hash of primitives.
      # Dispatch on `:type` to a SingleIdentifier subclass; default is
      # {Identifiers::Standard}.
      TYPE_KEY_TO_KLASS = {
        standard:        "Standard",
        conference:      "Conference",
        bundle:          "Bundle",
        joint_published: "JointPublished",
        dual_published:  "DualPublished",
        identical:       "Identical",
        tutorial_bundle: "TutorialBundle",
      }.freeze

      def self.create(type: nil, **opts)
        klass = resolve_create_class(type)
        klass.new(**coerce_create_attrs(opts, klass: klass))
      end

      def self.resolve_create_class(type)
        return Identifiers::Standard if type.nil?

        klass_name = TYPE_KEY_TO_KLASS[type.to_sym]
        raise ArgumentError, "Unknown CIE type: #{type.inspect}" unless klass_name

        Identifiers.const_get(klass_name)
      end

      def self.coerce_create_attrs(opts, klass:)
        attrs = {}
        attrs[:year] = opts[:year].to_s if opts[:year]
        attrs[:date_separator] = opts[:date_separator].to_s if opts[:date_separator]

        if (v = opts[:code] || opts[:number])
          attrs[:code] = Pubid::Cie::Components::Code.new(
            number:         v.to_s,
            part:           opts[:part]&.to_s,
            iteration:      opts[:iteration]&.to_s,
            style:          opts[:style]&.to_s,
            part_separator: opts[:part_separator]&.to_s,
          )
        end

        # Standard-only attributes
        if klass.attributes.key?(:s_prefix) && opts.key?(:s_prefix)
          attrs[:s_prefix] = opts[:s_prefix]
        end
        if klass.attributes.key?(:stage) && opts[:stage]
          attrs[:stage] = opts[:stage].to_s
        end
        attrs
      end
      private_class_method :resolve_create_class, :coerce_create_attrs
    end
  end
end
