require_relative "../identifier"
# frozen_string_literal: true
require_relative "../components/typed_stage"
require_relative "../components/factory"

module Pubid
  module Iec
    class Identifier < ::Pubid::Identifier
      # Long-tail document types that `create` may build but which are not in
      # Scheme.identifiers (the parse/build candidate set). Loaded lazily (not
      # at require time) to avoid a circular load with identifiers/base.rb.
      EXTRA_CREATE_KLASS_FILES = %w[
        conformity_assessment technology_report white_paper
        societal_technology_trend_report systems_reference_document
        interpretation_sheet
      ].freeze
      def self.parse(string)
        # Route URN strings to the URN parser (mirrors Iso::Identifier.parse)
        if Pubid::FormatDetector.detect(string) == :urn
          return Pubid::Iec::UrnParser.parse(string)
        end

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
      # See {Pubid::Iso::Identifier.create} for the shared design. Builds the
      # IEC `Components::*` subclasses (not the base ones) and populates
      # type/stage from the resolved TypedStage, so that a created identifier
      # round-trips `==` against the same identifier produced by `parse`.
      def self.create(type: nil, stage: nil, **opts)
        # A VAP suffix (CSV/RLV/…) is the outermost wrapper around the base
        # document (which may itself be amended); rebuild it first.
        if (vap = opts.delete(:vap))
          base = create(type: type, stage: stage, **opts)
          return Identifiers::VapIdentifier.new(
            base_identifier: base,
            vap_suffix: Components::VapSuffix.new(code: Array(vap).first.to_s),
          )
        end

        # Structured index rows carry amendments/corrigendums as a flat list
        # alongside the base document's keys; rebuild the supplement wrapping
        # the recursively-created base, mirroring what parse produces.
        if (supp = extract_supplement(opts))
          return build_supplement(supp, type: type, stage: stage, opts: opts)
        end

        # A nested base: holds the base document of a supplement whose own
        # number/year sit at the top level (e.g. an Interpretation Sheet).
        if (base_hash = opts.delete(:base))
          return build_based_supplement(type: type, base_hash: base_hash,
                                        opts: opts)
        end

        klass = resolve_create_class(type: type, stage: stage)
        attrs = coerce_create_attrs(opts)
        ts = resolve_create_typed_stage(klass, stage)
        if ts
          attrs[:typed_stage] = ts
          # Parse derives `type` and `stage` from the TypedStage (see
          # Builder#cast for :type_with_stage); mirror that here.
          attrs[:type] ||= ts.to_type
          attrs[:stage] ||= ts.to_stage
        end
        klass.new(**attrs)
      end

      # Pop a supplement spec off the flat opts hash, if present. Returns
      # { klass:, entry: } or nil. Amendments take precedence over
      # corrigendums for the (rare) consolidated rows that carry both.
      def self.extract_supplement(opts)
        if (amds = opts.delete(:amendments))
          { klass: Identifiers::Amendment, entry: Array(amds).first }
        elsif (cors = opts.delete(:corrigendums))
          { klass: Identifiers::Corrigendum, entry: Array(cors).first }
        end
      end

      # Build an Amendment/Corrigendum from { number:, year: } wrapping a base
      # identifier created from the remaining opts (which may themselves carry
      # a type, e.g. an amendment to a TR).
      def self.build_supplement(supp, type:, stage:, opts:)
        base = create(type: type, stage: stage, **opts)
        klass = supp[:klass]
        entry = supp[:entry] || {}
        ts = klass::TYPED_STAGES.find { |t| t.stage_code.to_sym == :published }
        attrs = { base_identifier: base, typed_stage: ts,
                  type: ts.to_type, stage: ts.to_stage }
        if (n = entry[:number])
          attrs[:number] = Components::Code.new(number: n.to_s)
        end
        if (y = entry[:year])
          attrs[:date] = ::Pubid::Components::Date.new(year: y.to_s)
        end
        klass.new(**attrs)
      end

      # Build a supplement whose base document is carried in a nested base:
      # hash (e.g. type: "ISH"); the supplement's own number/year are the
      # remaining top-level keys.
      def self.build_based_supplement(type:, base_hash:, opts:)
        klass = (type && locate_klass_by_type_or_short(type)) ||
                Identifiers::InternationalStandard
        base = create(**base_hash.transform_keys(&:to_sym))
        attrs = coerce_create_attrs(opts)
                .slice(:number, :part, :subpart, :date, :publisher, :copublishers)
        attrs[:base_identifier] = base
        if klass.const_defined?(:TYPED_STAGES) &&
            (ts = klass::TYPED_STAGES.find { |t| t.stage_code.to_sym == :published })
          attrs[:typed_stage] = ts
          attrs[:type] ||= ts.to_type
          attrs[:stage] ||= ts.to_stage
        end
        klass.new(**attrs)
      end

      # Coerce a 1.x-style attribute hash into IEC Component instances,
      # matching what the parser/builder produces. Unknown keys are dropped.
      def self.coerce_create_attrs(opts)
        out = {}
        if (v = opts[:publisher])
          out[:publisher] = Components::Publisher.new(body: v.to_s)
        end
        if (copubs = opts[:copublishers] || opts[:copublisher])
          out[:copublishers] =
            Array(copubs).map { |c| Components::Publisher.new(body: c.to_s) }
        end
        if (v = opts[:number])
          out[:number] = Components::Code.new(number: v.to_s)
        end
        # Indexes fold the subpart into a single "2-4" part string; parse
        # keeps part and subpart separate, so split to match.
        part, subpart = split_part(opts[:part], opts[:subpart])
        out[:part] = Components::Code.new(number: part.to_s) unless part.nil?
        out[:subpart] = Components::Code.new(number: subpart.to_s) unless subpart.nil?
        if (v = opts[:year])
          out[:date] = ::Pubid::Components::Date.new(year: v.to_s)
        end
        if (v = opts[:edition])
          out[:edition] = ::Pubid::Components::Edition.new(number: v)
        end
        if (v = opts[:language])
          out[:languages] = [::Pubid::Components::Language.new(code: v.to_s)]
        end
        out[:database] = true if opts[:database]
        out
      end

      # Split a folded "2-4" part into [part, subpart], matching parse. A part
      # without a dash (or an explicit subpart already supplied) is untouched.
      def self.split_part(part, subpart)
        return [nil, subpart] if part.nil?
        if subpart.nil? && part.to_s.include?("-")
          part.to_s.split("-", 2)
        else
          [part, subpart]
        end
      end

      def self.resolve_create_class(type:, stage:)
        if type && supplement_type?(type)
          # Supplements are built from amendments:/corrigendums: data (which
          # carry the supplement number/year); an explicit supplement `type:`
          # alone has no base to wrap.
          raise ArgumentError,
                "#{type} requires a base_identifier; pass amendments:/" \
                "corrigendums: instead of type:"
        end

        klass =
          if type
            locate_klass_by_type_or_short(type)
          elsif stage
            ts = safe_locate_typed_stage(stage)
            ts && locate_klass_by_type_or_short(ts.type_code)
          end
        klass || Identifiers::InternationalStandard
      end

      # True when `type` names a supplement identifier (Amendment/Corrigendum/
      # Fragment) by key, downcased key, or short abbreviation.
      def self.supplement_type?(type)
        t = type.to_s
        Scheme.supplement_identifiers.any? do |k|
          k.type[:key].to_s == t || k.type[:key].to_s == t.downcase ||
            Array(k.type[:short]).map(&:to_s).include?(t)
        end
      end

      # Structured indexes store `type:` as the registry key (:tr), an
      # upper-cased abbreviation ("TR"), or a title ("Technology Report").
      # Try each spelling, across every IEC identifier class (the create
      # candidate set is wider than Scheme.identifiers).
      def self.locate_klass_by_type_or_short(type)
        t = type.to_s
        all_create_klasses.detect { |k| k.type[:key].to_s == t } ||
          all_create_klasses.detect { |k| k.type[:key].to_s == t.downcase } ||
          all_create_klasses.detect { |k| Array(k.type[:short]).map(&:to_s).include?(t) } ||
          all_create_klasses.detect { |k| k.type[:title].to_s == t }
      end

      # All IEC identifier classes that `create` may build, including the
      # long-tail document types absent from Scheme.identifiers. Memoized;
      # the extra classes are required here (not at load time) to dodge the
      # circular require with identifiers/base.rb.
      def self.all_create_klasses
        @all_create_klasses ||= begin
          extra = EXTRA_CREATE_KLASS_FILES.map do |f|
            require_relative "identifiers/#{f}"
            Identifiers.const_get(camelize_klass_file(f))
          end
          Scheme.identifiers + extra
        end
      end

      def self.camelize_klass_file(file)
        file.split("_").map(&:capitalize).join
      end

      # IEC Scheme raises ArgumentError on miss instead of returning nil;
      # wrap so the same control flow works as in the ISO factory.
      def self.safe_locate_typed_stage(abbr)
        Scheme.locate_typed_stage_by_abbr(abbr.to_s)
      rescue ArgumentError
        nil
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
      private_class_method :resolve_create_class,
                           :safe_locate_typed_stage,
                           :resolve_create_typed_stage, :coerce_create_attrs,
                           :extract_supplement, :build_supplement,
                           :build_based_supplement,
                           :locate_klass_by_type_or_short, :all_create_klasses,
                           :camelize_klass_file, :supplement_type?,
                           :split_part
    end
  end
end
