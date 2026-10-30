# frozen_string_literal: true

module Pubid
  module Iec
    class Builder < Pubid::Builder::Base
      def locate_identifier_klass(parsed_hash)
        # Check for working programme
        if parsed_hash[:wp_stage]
          return Identifiers::WorkingDocument
        end

        # Check for technical group (committee identifier, no document number)
        if parsed_hash[:technical_committee] && !parsed_hash[:wd_number]
          return Identifiers::TechnicalGroup
        end

        # Check for working document
        if parsed_hash[:technical_committee] && parsed_hash[:wd_number]
          return Identifiers::WorkingDocument
        end

        # Check the `:type_with_stage` to determine the identifier class
        # :type_with_stage will be nil if it is an IS.
        typed_stage = locate_typed_stage(parsed_hash[:type_with_stage])

        Pubid::Iec.locate_type(typed_stage.type_code) ||
          raise(ArgumentError, "Unknown type code: #{typed_stage.type_code}")
      end

      # Bound-hash layer fields: the base, the first supplement and the
      # second supplement capture into disjoint key sets, so each
      # wrapper's data can be peeled off the flat hash by name.
      SUPP_KEYS = %i[supp_type_with_stage supp_number_with_part
                     supp_stage_iteration supp_date supp_undated_marker
                     supp_edition].freeze
      SUPP2_KEYS = %i[supp2_type_with_stage supp2_number_with_part
                      supp2_stage_iteration supp2_date supp2_undated_marker
                      supp2_edition].freeze
      FRAG_ABBRS = (Identifiers::FragmentIdentifier::TYPED_STAGES
        .flat_map(&:abbr) + ["FRAGC"]).freeze
      # third_part's /FRAGN notation wraps the OUTERMOST layer, so every
      # early-return branch applies it and every inner base build strips
      # it.
      FRAG_NOTATION_KEYS = %i[fragment_type fragment_number].freeze

      # third_part's /FRAGN notation (distinct from a FRAG typed stage)
      # wraps the finished identifier.
      def apply_fragment_notation(identifier, parsed_hash)
        if parsed_hash[:fragment_type] && parsed_hash[:fragment_number]
          return wrap_with_fragment(identifier,
                                    parsed_hash[:fragment_number].to_s,
                                    nil, Pubid::Iec.locate_stage("FRAG"))
        end
        identifier
      end

      def build(parsed_hash)
        all_parts = parsed_hash.delete(:all_parts)

        # Second supplement layer (/AMD1:2018/COR1:2019): build the
        # first-supplement form, then wrap the second supplement around
        # it.
        if parsed_hash[:supp2_type_with_stage]
          supp2 = supplement_fields(parsed_hash, SUPP2_KEYS)
          inner = build(parsed_hash.reject { |key, _| SUPP2_KEYS.include?(key) })
          return apply_fragment_notation(wrap_supplement_layer(inner, supp2),
                                         parsed_hash)
        end

        # Sheet + supplement (…/1:1994/COR1): the sheet wraps the base,
        # the supplement wraps the sheet. build re-enters the sheet
        # branch for the base.
        if parsed_hash[:sheet_number] && parsed_hash[:supp_type_with_stage]
          supp = supplement_fields(parsed_hash, SUPP_KEYS)
          base_hash = parsed_hash.reject { |key, _| SUPP_KEYS.include?(key) }
          sheet_id = build(base_hash)
          return apply_fragment_notation(wrap_supplement_layer(sheet_id, supp),
                                         parsed_hash)
        end

        # Sheet notation (…/1:1994 or …/1): the remaining fields are the
        # sheet's base identifier.
        if parsed_hash[:sheet_number]
          sheet_number = parsed_hash.delete(:sheet_number)
          sheet_year = parsed_hash.delete(:sheet_year)
          rest = parsed_hash.reject { |key, _| FRAG_NOTATION_KEYS.include?(key) }
          return apply_fragment_notation(
            wrap_with_sheet(build(rest), sheet_number, sheet_year),
            parsed_hash,
          )
        end

        # Standalone supplement (IEC/AMD 1:2017 — no base designation):
        # the supplement's own fields are the primary ones.
        if parsed_hash[:supp_type_with_stage] && !parsed_hash[:number_with_part] &&
            !parsed_hash[:trf_org] && !parsed_hash[:technical_committee]
          return build(standalone_supplement_hash(parsed_hash))
        end

        # Extract FRAG/FRAGC indicator if present
        frag_abbrs = Pubid::Iec::Identifiers::FragmentIdentifier::TYPED_STAGES
          .flat_map(&:abbr)
        is_fragment = frag_abbrs.include?(parsed_hash[:type_with_stage]) ||
          parsed_hash[:type_with_stage] == "FRAGC" ||
          frag_abbrs.include?(parsed_hash[:supp_type_with_stage]) ||
          parsed_hash[:supp_type_with_stage] == "FRAGC"
        fragment_typed_stage = nil
        fragment_number = nil
        fragment_edition = nil

        if is_fragment
          # For FRAG typed stages, look up the fragment's own typed stage
          fragment_typed_stage = Pubid::Iec.locate_stage(parsed_hash[:type_with_stage] ||
            parsed_hash[:supp_type_with_stage])

          # FRAGC is a rendering notation, not a typed stage abbreviation;
          # fall back to the canonical "FRAG" typed stage
          fragment_typed_stage ||= Pubid::Iec.locate_stage("FRAG")

          # For FRAG/FRAGC, we need to build the base Amendment/Corrigendum
          # then wrap it with FragmentIdentifier
          if parsed_hash[:supp_type_with_stage] &&
              (parsed_hash[:number_with_part] || parsed_hash[:trf_org])
            # FRAG riding the supplement layer: the base is the rest.
            fragment_number = parsed_hash[:supp_number_with_part].to_s
            fragment_edition = parsed_hash[:supp_edition]
            base_id = build(parsed_hash.reject do |key, _|
              SUPP_KEYS.include?(key) || FRAG_NOTATION_KEYS.include?(key)
            end)
            return apply_fragment_notation(
              wrap_with_fragment(base_id, fragment_number,
                                 fragment_edition, fragment_typed_stage),
              parsed_hash,
            )
          end

          # For FRAG/FRAGC, we need to build the base Amendment/Corrigendum
          # then wrap it with FragmentIdentifier
          if parsed_hash[:number_with_part]
            fragment_number = parsed_hash[:number_with_part].to_s
          end

          # Extract edition for fragment
          fragment_edition = parsed_hash.delete(:edition)

          # Build the base identifier (Amendment/Corrigendum) directly
          if parsed_hash[:base]
            base_id = build(parsed_hash[:base])
            return wrap_with_fragment(base_id, fragment_number,
                                      fragment_edition, fragment_typed_stage)
          end
        end

        # Check for TRF with CISPR - build embedded identifier
        trf_org = parsed_hash.delete(:trf_org)
        if trf_org && parsed_hash[:number_with_part]
          # Build CISPR identifier without year
          cispr_number = parsed_hash.delete(:number_with_part)
          cispr_id = Identifiers::InternationalStandard.new(
            publisher: Components::Publisher.new(body: "CISPR"),
          )
          # Set number via cast
          number_components = cast(:number_with_part, cispr_number)
          attrs = cispr_id.class.attributes
          number_components.each_pair do |k, v|
            cispr_id.public_send("#{k}=", v) if attrs.key?(k.to_sym)
          end
          parsed_hash[:cispr_identifier] = cispr_id
        end

        # Supplement over a base designation (…/AMD1:2021): build the
        # base from the remaining fields, then wrap.
        if parsed_hash[:supp_type_with_stage]
          supp = supplement_fields(parsed_hash, SUPP_KEYS)
          base_hash = parsed_hash.reject do |key, _|
            SUPP_KEYS.include?(key) || FRAG_NOTATION_KEYS.include?(key)
          end
          base = build(base_hash)
          return apply_fragment_notation(wrap_supplement_layer(base, supp),
                                         parsed_hash)
        end

        # Extract and store wrapper data before building
        consolidated_supplements_data = parsed_hash.delete(:consolidated_supplements)
        vap_suffix_data = parsed_hash.delete(:vap_suffix)
        # Note: sheet_number and sheet_year are now handled in sheet_identifier check above
        fragment_type_data = parsed_hash.delete(:fragment_type)
        fragment_number_data = parsed_hash.delete(:fragment_number)

        # Instantiate the identifier based on the typed stage
        identifier = locate_identifier_klass(parsed_hash).new

        # For French GUIDE entries: "Guide IEC 51:1999"
        if type_with_stage_fr = parsed_hash.delete(:type_with_stage_fr)
          parsed_hash[:type_with_stage] = type_with_stage_fr
        end

        assign_attributes(identifier, parsed_hash)

        # Detect rendering style from parsed abbreviation.
        #
        # UNREACHABLE TODAY: no IEC identifier class declares a
        # `rendering_style` attribute, so this whole block never runs. Its
        # `original_abbr` reads below are therefore NOT a live consumer of that
        # field — which is why `original_abbr` can be left nil on both the parse
        # and the from_hash paths (see Identifier.published_typed_stage). The
        # long-vs-short stage spelling is already collapsed: "…/Amd 1:2017"
        # renders back as "…/AMD1:2017". Do not treat this as working code.
        if identifier.class.attributes.key?(:rendering_style) && identifier.typed_stage
          ts = identifier.typed_stage

          # Detect IEC format from parsed abbreviation
          # IEC uses space to indicate long form: "Amd 1", "Cor 1"
          # No space indicates short form: "AMD1", "COR1"
          stage_format_long = if ts.long_abbr && ts.original_abbr&.include?(" ")
                                true # Long form has space: "Amd 1", "Cor 1"
                              elsif ts.short_abbr && ts.original_abbr && !ts.original_abbr.include?(" ")
                                false  # Short form: "AMD1", "COR1", "CDV", "FDIS"
                              else
                                false  # Default to short/canonical
                              end

          # Detect language code format from parsed languages
          langs = if identifier.class.attributes.key?(:languages)
                    identifier.languages
                  end
          with_language_code = if langs&.any?
                                 # Check if original_code was single-char (E, F, R, A, S, D)
                                 first_lang = langs.first
                                 if first_lang.is_a?(::Pubid::Components::Language) && first_lang.original_code && first_lang.original_code.length == 1
                                   :single
                                 else
                                   :iso # 2-char codes (en, fr, ru, ar, es, de)
                                 end
                               else
                                 :none
                               end

          # with_date is always true for base identifiers (show the date if present)
          # Only supplements might have undated references
          with_date = true

          # Create custom rendering style based on parsed format
          identifier.rendering_style = RenderingStyle.new(
            with_language_code: with_language_code,
            stage_format_long: stage_format_long,
            with_date: with_date,
          )
        end

        # After building base identifier, apply wrappers
        if fragment_type_data && fragment_number_data
          frag_ts = Pubid::Iec.locate_stage("FRAG")
          identifier = wrap_with_fragment(identifier, fragment_number_data.to_s,
                                          nil, frag_ts)
        end
        # Note: sheet wrapping is now handled earlier in build method for sheet_identifier pattern
        if consolidated_supplements_data
          identifier = wrap_with_consolidated(identifier,
                                              consolidated_supplements_data)
        end
        if vap_suffix_data
          identifier = wrap_with_vap(identifier,
                                     vap_suffix_data)
        end

        # "(all parts)" and the "ser" URN slot name every part of the
        # document, so they wrap the document, which holds no mark itself.
        all_parts ? identifier.to_all_parts : identifier
      end

      def handle_key(identifier, key, value)
        if key == :joint_identifier
          identifier.additional_identifiers ||= []
          identifier.additional_identifiers << value
          true
        else
          false
        end
      end

      # The IEC builder's own `build` method drives identifier construction
      # (it locates the right class per parsed hash), so the parent class's
      # `@identifier_class` slot is never read. Provide a placeholder so
      # `Builder.new` doesn't fail with NotImplementedError.
      def default_identifier_class
        Identifiers::InternationalStandard
      end

      # Look up a typed stage by abbreviation via the self-describing
      # `Pubid::Iec` module instead of an injected scheme instance.
      def locate_typed_stage(typed_stage_string)
        typed_stage_string = "" if typed_stage_string.nil?
        Pubid::Iec.locate_stage(typed_stage_string) ||
          raise(ArgumentError, "Unknown type abbreviation: '#{typed_stage_string}'")
      end

      # Wrap identifier with FragmentIdentifier for /FRAGN notation
      def wrap_with_fragment(base, fragment_number,
      edition_data = nil, typed_stage = nil)
        fragment = Identifiers::FragmentIdentifier.new(
          base: base,
          fragment_number: fragment_number,
        )

        # Set typed stage if provided
        fragment.typed_stage = typed_stage if typed_stage

        # Set edition if provided
        if edition_data
          fragment.edition = cast(:edition, edition_data)
        end

        fragment
      end

      # Wrap identifier with SheetIdentifier for /N:YEAR notation
      def wrap_with_sheet(base, sheet_number, sheet_year)
        # Only pass year if it's present
        year_value = sheet_year&.to_s

        Identifiers::SheetIdentifier.new(
          base: base,
          sheet_number: sheet_number.to_s,
          year: year_value,
        )
      end

      # Peels one supplement layer's supp_* / supp2_* fields off the
      # flat bound hash.
      def supplement_fields(parsed_hash, keys)
        parsed_hash.slice(*keys).transform_keys { |key|
          key.to_s.delete_prefix("supp").delete_prefix("2_").gsub(/\A_/, "").to_sym
        }
      end

      # Wraps one supplement layer around its base: a FRAG/FRAGC layer
      # is a FragmentIdentifier wrapper, anything else is an
      # Amendment/Corrigendum built from the layer's fields.
      def wrap_supplement_layer(base, supp)
        abbr = supp[:type_with_stage].to_s
        if FRAG_ABBRS.include?(abbr)
          typed_stage = Pubid::Iec.locate_stage(abbr) ||
                        Pubid::Iec.locate_stage("FRAG")
          return wrap_with_fragment(base, supp[:number_with_part].to_s,
                                    supp[:edition], typed_stage)
        end
        wrap_with_supplement(base, build_supplement(supp))
      end

      # Materializes one supplement (Amendment/Corrigendum/…) from its
      # layer's fields.
      def build_supplement(fields)
        typed_stage = locate_typed_stage(fields[:type_with_stage])
        identifier_class = Pubid::Iec.locate_type(typed_stage.type_code) ||
          raise(ArgumentError, "Unknown type code: #{typed_stage.type_code}")

        supplement = identifier_class.new
        supp_attrs = identifier_class.attributes
        if supp_attrs.key?(:number) && fields[:number_with_part]
          supplement.number = fields[:number_with_part].to_s
        end
        if supp_attrs.key?(:date)
          if fields[:date]
            supplement.date = parse_date(fields[:date])
          elsif fields[:undated_marker]
            supplement.date = Pubid::Components::Date.new(undated: true)
          end
        end
        if supp_attrs.key?(:edition) && fields[:edition]
          supplement.edition = Pubid::Components::Edition.new(number: fields[:edition].to_s)
        end
        supplement.typed_stage = typed_stage
        supplement
      end

      # A standalone supplement (IEC/AMD 1:2017) has no base designation:
      # its supp_* fields become the primary ones.
      def standalone_supplement_hash(parsed_hash)
        parsed_hash
          .slice(:publisher, :copublishers, :type_with_stage_fr,
                 :languages, :fragment_type, :fragment_number, :all_parts)
          .merge(
            type_with_stage: parsed_hash[:supp_type_with_stage],
            number_with_part: parsed_hash[:supp_number_with_part],
            stage_iteration: parsed_hash[:supp_stage_iteration],
            date: parsed_hash[:supp_date],
            undated_marker: parsed_hash[:supp_undated_marker],
            edition: parsed_hash[:supp_edition],
          ).compact
      end

      # Wrap base identifier with supplement (Amendment/Corrigendum)
      def wrap_with_supplement(base, supplement)
        supplement.base = base
        supplement
      end

      # Wrap identifier with ConsolidatedIdentifier for +AMD chains
      def wrap_with_consolidated(base, supplements_data)
        supplements = supplements_data.filter_map do |supp|
          type = supp[:supplement_type].to_s
          number = supp[:supplement_number].to_s
          year = supp[:supplement_year]

          # Only create Date component if year is present
          date_component = year ? Pubid::Components::Date.new(year: year.to_s) : nil

          if type == "AMD"
            Identifiers::Amendment.new(
              number: number,
              date: date_component,
            )
          elsif type == "COR"
            Identifiers::Corrigendum.new(
              number: number,
              date: date_component,
            )
          end
        end

        Identifiers::ConsolidatedIdentifier.new(
          identifiers: [base] + supplements,
        )
      end

      # Wrap identifier with VapIdentifier for one or more VAP codes
      # (e.g. "CSV" or "EXV-CMV").
      def wrap_with_vap(base, vap_suffix_data)
        vap = vap_suffix_data.to_s.split("-")

        # Extract edition - need to go deep for ConsolidatedIdentifier
        edition = nil
        if base.is_a?(Identifiers::ConsolidatedIdentifier)
          # Edition is on the first identifier (base document)
          base_first = base.identifiers.first
          if base_first && base_first.class.attributes.key?(:edition)
            edition = base_first.edition
            base_first.edition = nil
          end
        elsif base.class.attributes.key?(:edition)
          edition = base.edition
          base.edition = nil
        end

        Identifiers::VapIdentifier.new(
          base: base,
          vap: vap,
          edition: edition,
        )
      end

      def convert_roman_to_integer(roman_numeral)
        return roman_numeral if roman_numeral.to_s.upcase == "X"

        super
      end

      # IEC normalizes em/en dashes to hyphens but preserves slashes and
      # spaces, which can be semantically meaningful in IEC identifiers.
      def normalize_number_with_part(value)
        value.to_s.tr(Parser::DASH_CHARS.join, "-")
      end

      def cast(type, value)
        case type
        when :base
          # If it has a base identifier, we need to build a supplement
          # We assume that the base identifier is already a valid Identifier object
          build(value)

        when :publisher
          # CEI is IEC's French spelling (pubid#488): a French-printed
          # "CEI …" identifier is the IEC publisher; the canonical
          # rendering prints IEC.
          Components::Publisher.new(body: value == "CEI" ? "IEC" : value)

        when :copublishers
          if value.nil? || value.empty?
            nil
          else
            value.map do |copublisher|
              Components::Publisher.new(body: copublisher[:copublisher])
            end
          end

        when :technical_committee, :subcommittee, :wd_number, :wd_stage, :wd_language, :wp_stage, :wp_type
          # Working document/programme fields - just return as string
          value.to_s

        when :cispr_identifier
          # CISPR identifier object for TRF
          value

        when :number
          # Plain number for sub-org identifiers (CA, IECQ CS, IECQ OD)
          { number: value.to_s }

        when :number_with_part
          # "60038" (no part)
          # or "60038-1" ('1' is part)
          # or "60038-1-2" ('1' is part, '2' is subpart)
          # or "29110-5-1-1" ('5' is part, '1-1' is subpart)
          parse_number_with_part(value)

        when :type_with_stage
          # "WD"
          # "TS"
          # "Guide"
          # FRAG typed stages are handled in the is_fragment check above

          iteration = value.to_s.match(/(\d+)$/)
          value = value.to_s.sub(iteration.to_s, "")
          typed_stage = locate_typed_stage(value || "")

          ## IMPORTANT!!
          # Always use TypedStage in an Identifier or separate Type and Stage.
          {
            stage: typed_stage.to_stage,
            type: typed_stage.to_type,
            typed_stage: typed_stage,
          }
        when :stage_iteration
          # "1" or "2"
          Pubid::Components::Iteration.new(number: value.to_s)

        when :date
          parse_date(value)

        when :undated_marker
          # ISO/IEC undated reference (e.g. "IEC 60050:--") — explicit
          # publication-date slot with no year; round-trips via date.render.
          { date: Pubid::Components::Date.new(undated: true) }

        when :edition
          # Coerce to String: the parsed value may be a Parslet::Slice, which
          # Edition.number (Type::Value) would store verbatim and serialize as a
          # !ruby/object:Parslet::Slice node — unloadable by the index reader's
          # YAML.safe_load(permitted_classes: [Symbol]).
          Pubid::Components::Edition.new(number: value&.to_s)

        when :sheet_number
          value.to_s

        when :sheet_year
          value.to_s

        when :languages
          parse_languages(value)

        when :all_parts
          # Set all_parts boolean attribute directly on identifier (matches ISO builder)
          true

        when :database
          # Database flag - return true if DB suffix present
          true

        # Handle joint identifiers with ISO
        when :joint_identifier
          case value[:publisher]
          when "ISO"
            Pubid::Iso.build_from_parse(value)
          end

        else
          raise ArgumentError, "Unknown parameter type: #{type}"
        end
      end
    end
  end
end

Pubid::Iec::Builder.prepend(Pubid::Builder::AllPartsWrap)
