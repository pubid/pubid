# frozen_string_literal: true

require_relative "parser"
require_relative "builder"
require_relative "identifiers"
require_relative "components/sector"
require_relative "components/series"
require_relative "components/code"

module Pubid
  module Itu
    module Identifier
      def self.parse(identifier)
        parsed = Parser.parse(identifier)
        Builder.build(parsed)
      rescue Parslet::ParseFailed => e
        raise "Failed to parse ITU identifier '#{identifier}': #{e.message}"
      end

      # Factory mirroring pubid 1.x's `Pubid::Itu::Identifier.create` API.
      # Dispatch on `:type`:
      #   * nil → Recommendation (or SpecialPublication for series "OB")
      #   * :recommendation     → Identifiers::Recommendation
      #   * :annex              → Identifiers::Annex
      #   * :special_publication → Identifiers::SpecialPublication
      #
      # Component-typed kwargs are accepted as primitives and coerced:
      #   * sector: "T"   → Components::Sector.new(sector: "T")
      #   * series: "X"   → Components::Series.new(series: "X")
      #   * number: "509" → Components::Code.new(number: "509")
      #   * year: "2020"  → Pubid::Components::Date.new(year: "2020")
      TYPE_KEY_TO_KLASS = {
        recommendation:      "Recommendation",
        annex:               "Annex",
        special_publication: "SpecialPublication",
      }.freeze

      def self.create(type: nil, **kwargs)
        # Backward-compat: nil type + series "OB" → SpecialPublication.
        if type.nil? && kwargs[:series].to_s == "OB"
          return create_special_publication(**kwargs)
        end

        klass = resolve_create_class(type)
        klass.new(**coerce_create_attrs(kwargs, klass: klass))
      end

      def self.resolve_create_class(type)
        return Identifiers::Recommendation if type.nil?

        klass_name = TYPE_KEY_TO_KLASS[type.to_sym]
        raise ArgumentError, "Unknown ITU type: #{type.inspect}" unless klass_name

        Identifiers.const_get(klass_name)
      end

      # Backward-compat helper retained for the OB-series shortcut.
      def self.create_special_publication(number:, series: "OB", date: nil,
                                          language: nil)
        Identifiers::SpecialPublication.new(
          series:   Components::Series.new(series: series.to_s),
          code:     Components::Code.new(number: number.to_s),
          date:     date,
          language: language&.to_s,
        )
      end

      def self.coerce_create_attrs(opts, klass: nil)
        attrs = {}
        if (v = opts[:sector])
          attrs[:sector] = if v.is_a?(Components::Sector)
                             v
                           else
                             Components::Sector.new(sector: v.to_s.upcase)
                           end
        end
        if (v = opts[:series])
          attrs[:series] = if v.is_a?(Components::Series)
                             v
                           else
                             Components::Series.new(series: v.to_s)
                           end
        end
        if opts[:number] || opts[:code]
          code_value = opts[:code]
          if code_value.is_a?(Components::Code)
            attrs[:code] = code_value
          else
            attrs[:code] = Components::Code.new(
              number:    (opts[:number] || code_value).to_s,
              subseries: opts[:subseries]&.to_s,
              parts:     opts[:parts] ? Array(opts[:parts]).map(&:to_s) : nil,
            )
          end
        end
        if (v = opts[:year])
          attrs[:date] = Pubid::Components::Date.new(year: v.to_s)
        end
        attrs[:date] = opts[:date] if opts[:date].is_a?(Pubid::Components::Date)
        attrs[:language] = opts[:language].to_s if opts[:language]

        # Pass through any subclass-specific kwarg the chosen class
        # declares (e.g. Annex#base) — preserves callers that already pass
        # an explicit attribute that our coercion table doesn't cover.
        if klass
          consumed = %i[sector series number code subseries parts year date
                        language]
          opts.each do |k, v|
            next if consumed.include?(k) || attrs.key?(k)
            attrs[k] = v if klass.attributes.key?(k)
          end
        end
        attrs
      end
      private_class_method :resolve_create_class, :coerce_create_attrs
    end
  end
end
