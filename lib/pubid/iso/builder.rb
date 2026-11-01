# frozen_string_literal: true

module Pubid
  module Iso
    class Builder < Pubid::Builder::Base
      def initialize
        # No state needed: lookups are delegated to the Pubid::Iso module.
      end

      # Override the base implementation to avoid relying on @scheme.
      # @param typed_stage_string [String, nil]
      # @return [Pubid::Components::TypedStage, nil]
      def locate_typed_stage(typed_stage_string)
        Pubid::Iso.locate_stage(typed_stage_string.to_s)
      end

      def locate_identifier_klass(parsed_hash)
        # If there is a joint_identifier, we need to use a CombinedIdentifier
        # which takes `base` and `additional_identifiers`
        if parsed_hash[:joint_identifier]
          return CombinedIdentifier
        end

        # If there are supplements, we need to use a BundledIdentifier
        # which takes `base_document` and `supplements`
        if parsed_hash[:supplements]
          return BundledIdentifier
        end

        # TC documents are identified by the presence of tc_type
        if parsed_hash[:tc_type]
          return Identifiers::TcDocument
        end

        # Bare TC reference (pubid-iso#285): "184/SC 4/WG 12 N10291" — the
        # ISO/TC route without the ORIGINATOR prefix. tc_type is absent by
        # construction; sc_type is the route's required segment and cannot
        # appear on a standard identifier.
        if parsed_hash[:sc_type] && parsed_hash[:tc_number]
          parsed_hash[:tc_type] = "TC"
          return Identifiers::TcDocument
        end

        # An explicit document type (e.g. from a URN's `:tr:`/`:ts:` token) pins
        # the class regardless of the stage. The stage and type are separate URN
        # fields, but the stage is later folded into `:type_with_stage` (e.g.
        # "WDA" for 90.93), which would otherwise mis-resolve the class to the
        # stage's owning type (IS). Consume the hint here, before assign_attributes.
        if (doc_type = parsed_hash.delete(:document_type))
          type_stage = locate_typed_stage(doc_type)
          return Pubid::Iso.locate_type(type_stage.type_code) if type_stage
        end

        # Check the `:type_with_stage` to determine the identifier class
        # 1. :type_with_stage will be nil if:
        # a) It is an IS.
        # b) It is a Directive Supplements. The "SUP" keyword may be entirely missing, and hence nil. If the base type_with_stage is a directive, then if the type_with_stage is blank, it is a directive supplement.

        if parsed_hash[:type_with_stage].nil? && parsed_hash[:base] && parsed_hash[:base][:type_with_stage] == "DIR"
          # Directive Supplement without "SUP" keyword
          parsed_hash[:type_with_stage] = "SUP"
        end

        typed_stage = locate_typed_stage(parsed_hash[:type_with_stage])

        Pubid::Iso.locate_type(typed_stage.type_code)
      end

      # Bound-hash layer fields: the grammar captures every supplement
      # layer into a disjoint prefix (supp_ on the first supplement,
      # supp2_ / supp3_ on the chain's later layers, isor_supp_ on an
      # ISO/R supplement, dsupp_ on a directive supplement), so each
      # wrapper's fields peel off the flat bound hash by prefix and
      # re-key onto the builder-input names.
      SUPPLEMENT_LAYERS = [
        {
          prefix: "supp3_",
          keys: %i[supp3_type_with_stage supp3_number_with_part supp3_stage_iteration
                   supp3_number supp3_date supp3_undated_marker supp3_edition
                   supp3_languages supp3_all_parts],
          plain_third_part: false,
        },
        {
          prefix: "supp2_",
          keys: %i[supp2_type_with_stage supp2_number_with_part supp2_stage_iteration
                   supp2_number supp2_date supp2_undated_marker supp2_edition
                   supp2_languages supp2_all_parts],
          plain_third_part: false,
        },
        {
          prefix: "supp_",
          keys: %i[supp_type_with_stage supp_number_with_part supp_stage_iteration
                   supp_number supp_date supp_undated_marker supp_edition
                   supp_languages supp_all_parts],
          # The first supplement's third_part keeps the plain names: the
          # base document's own edition captures as base_edition, so the
          # plain edition/languages/all_parts belong to the supplement.
          plain_third_part: true,
        },
        {
          prefix: "isor_supp_",
          keys: %i[isor_supp_type_with_stage isor_supp_number_with_part
                   isor_supp_stage_iteration isor_supp_date isor_supp_undated_marker],
          plain_third_part: true,
        },
      ].freeze
      PLAIN_THIRD_PART_KEYS = %i[edition languages all_parts].freeze

      # Directive-supplement layer (ISO/IEC DIR 1 ISO SUP): dsupp_* fields
      # re-key onto the supplement hash, the base directive's fields stay
      # plain.
      DSUPP_KEYS = %i[dsupp_publisher dsupp_type_with_stage dsupp_date
                      dsupp_undated_marker dsupp_edition dsupp_languages
                      dsupp_all_parts].freeze

      # Bundled directive items capture into position-scoped prefixes
      # (one per bundle item — the engine's array-group harvest pads
      # non-firing reps with empty hashes, parsanol-ruby#399, so bundle
      # items cannot collect through an array binding).
      BUNDLE_PREFIXES = %w[bs1_ bs2_ bs3_].freeze

      # Joint identifier (ISO x|IDF y): the IDF side captures under idf_*
      # names; they re-key onto the tree-shape hash Pubid::Idf.build_from_parse
      # consumes.
      IDF_KEYS = %i[idf_publisher idf_type_with_stage idf_stage_iteration
                    idf_number_with_part idf_date idf_languages idf_all_parts
                    idf_supp_type_with_stage idf_supp_number_with_part2
                    idf_supp_stage_iteration2 idf_supp_date2
                    idf_supp_undated_marker].freeze
      IDF_REKEY = {
        idf_publisher: :publisher,
        idf_type_with_stage: :type_with_stage,
        idf_stage_iteration: :stage_iteration,
        idf_number_with_part: :number_with_part,
        idf_date: :date,
        idf_languages: :languages,
        idf_all_parts: :all_parts,
      }.freeze
      IDF_SUPP_REKEY = {
        idf_supp_type_with_stage: :type_with_stage,
        idf_supp_number_with_part2: :number_with_part,
        idf_supp_stage_iteration2: :stage_iteration,
        idf_supp_date2: :date,
        idf_supp_undated_marker: :undated_marker,
      }.freeze

      def build(parsed_hash)
        # "(all parts)" and the ":ser" URN name every part of the document,
        # so they build an AllPartsIdentifier around the document (the URN
        # parser puts the key on the outermost identifier for the same
        # reason). The document itself holds no all-parts mark.
        all_parts = parsed_hash.delete(:all_parts)

        # The copublisher tail captures as one scalar span ("/IEC/IEEE");
        # split it into the {copublisher:} element hashes the merge and
        # the :copublishers cast consume. A pre-built array (the URN
        # parser) passes through.
        if parsed_hash[:copublishers].is_a?(String)
          parsed_hash[:copublishers] = parsed_hash.delete(:copublishers)
            .split("/").map(&:strip).reject(&:empty?)
            .map { |cp| { copublisher: cp } }
        end

        # Peel supplement layers outermost-first: each layer re-keys its
        # prefixed fields onto the builder-input names, nests the rest as
        # its :base, and re-enters build — the same shape the grammar's
        # tree used to nest.
        SUPPLEMENT_LAYERS.each do |layer|
          next unless parsed_hash.keys.any? do |key|
            key.to_s.start_with?(layer[:prefix])
          end

          return build_supplement_layer(parsed_hash, layer, all_parts)
        end

        # Joint identifier (ISO x|IDF y): the base designation's fields
        # stay plain, the IDF side re-keys into the tree-shape hash the
        # IDF builder consumes, and the pair routes through the
        # CombinedIdentifier via the :joint_identifier key.
        if parsed_hash.key?(:idf_publisher)
          return build_joint_identifier(parsed_hash, all_parts)
        end

        # Directive supplement (ISO/IEC DIR 1 ISO SUP): the dsupp_* fields
        # are the supplement's, the plain fields its base directive's.
        if parsed_hash.key?(:dsupp_type_with_stage)
          return build_directive_supplement(parsed_hash, all_parts)
        end

        # Bundled directives ("DIR 1:2022 + IEC SUP:2022"): the plain
        # fields are the base document's; each bundle item captures under
        # its bs1_/bs2_/bs3_ prefix.
        if BUNDLE_PREFIXES.any? do |prefix|
          parsed_hash.keys.any? { |key| key.to_s.start_with?(prefix) }
        end
          return build_bundled(parsed_hash, all_parts)
        end

        # For ISO/R legacy format, split into publisher and type
        if parsed_hash[:iso_r_prefix]
          parsed_hash[:publisher] = "ISO"
          parsed_hash[:type_with_stage] = "R"
          parsed_hash.delete(:iso_r_prefix)
        end

        # The base document's own edition captures as base_edition (the
        # supplement layers' third_part editions own the plain key), so
        # it re-keys onto :edition only here — at the innermost base,
        # after every wrapper layer has been peeled off.
        parsed_hash[:edition] = parsed_hash.delete(:base_edition) if parsed_hash.key?(:base_edition)

        # For NSB-prefixed identifiers (FprISO, WD/ISO), set stage
        if parsed_hash[:nsb_stage]
          nsb_stage = parsed_hash.delete(:nsb_stage)
          # Map NSB stage to typed stage
          case nsb_stage
          when "Fpr"
            parsed_hash[:type_with_stage] = "PRF"
          when "WD"
            parsed_hash[:type_with_stage] = "WD"
          end
        end

        # For French GUIDE entries: "Guide ISO/CEI 37:1995". The rename
        # must happen BEFORE class selection — locate_identifier_klass
        # reads :type_with_stage, and the bound map of a guide-first
        # spelling carries the type under :type_with_stage_fr, so
        # deferring the rename selected the default International
        # Standard class for every guide-first reference.
        if (type_with_stage_fr = parsed_hash.delete(:type_with_stage_fr))
          parsed_hash[:type_with_stage] = type_with_stage_fr
        end

        # Instantiate the identifier based on the typed stage
        identifier = locate_identifier_klass(parsed_hash).new

        # For DirectivesSupplement, rename :publisher to :supplement_publisher
        if identifier.is_a?(Identifiers::DirectivesSupplement) && parsed_hash[:publisher]
          parsed_hash[:supplement_publisher] = parsed_hash.delete(:publisher)
        end

        # Merge copublishers into publisher object
        if parsed_hash[:publisher] && parsed_hash[:copublishers]
          copublisher_strings = parsed_hash[:copublishers].map do |cp|
            cp[:copublisher]
          end
          parsed_hash[:publisher] = {
            publisher: parsed_hash[:publisher],
            copublisher: copublisher_strings,
          }
        end

        assign_attributes(identifier, parsed_hash)

        # If typed_stage, stage, or type are still nil after building,
        # set them to the default International Standard values
        if identifier.typed_stage.nil?
          default_typed_stage = Pubid::Iso.locate_stage("")
          identifier.typed_stage = default_typed_stage
          identifier.stage = default_typed_stage.to_stage
          identifier.type = default_typed_stage.to_type
        end

        all_parts ? identifier.to_all_parts : identifier
      end

      # "ISO 5537|IDF 26": the ISO side builds as the combined
      # identifier's base, the IDF side re-keys into the tree-shape hash
      # Pubid::Idf.build_from_parse consumes and lands in
      # :joint_identifier.
      def build_joint_identifier(hash, all_parts)
        base_fields = hash.except(*IDF_KEYS)
        idf_fields = rekey(hash.slice(*IDF_REKEY.keys), IDF_REKEY)

        if (supp_keys = IDF_SUPP_REKEY.keys & hash.keys).any?
          idf_fields = {
            base: idf_fields,
            **rekey(hash.slice(*supp_keys), IDF_SUPP_REKEY),
          }
        end

        inner = { base: base_fields, joint_identifier: idf_fields }
        inner[:all_parts] = all_parts if all_parts
        build(inner)
      end

      # One supplement layer: re-key the layer's prefixed fields, move
      # the shared plain third-part fields onto the layer where the
      # grammar captures them there, nest everything else as the layer's
      # base, and re-enter build.
      def build_supplement_layer(hash, layer, all_parts)
        prefix = layer[:prefix]
        layer_hash = hash.select { |key, _| key.to_s.start_with?(prefix) }
        fields = rekey_prefix(layer_hash, prefix)

        if layer[:plain_third_part]
          third_part = hash.slice(*PLAIN_THIRD_PART_KEYS)
          fields = { **third_part, **fields }
        end

        rest = hash.except(*layer_hash.keys)
        rest = rest.except(*PLAIN_THIRD_PART_KEYS) if layer[:plain_third_part]

        inner = { **fields, base: rest }
        inner[:all_parts] = all_parts if all_parts
        build(inner)
      end

      def build_directive_supplement(hash, all_parts)
        fields = rekey_prefix(hash.slice(*DSUPP_KEYS), "dsupp_")
        rest = hash.except(*DSUPP_KEYS)

        inner = { **fields, base: rest }
        inner[:all_parts] = all_parts if all_parts
        build(inner)
      end

      # Bundled directives: each bundle item's prefixed fields re-key to
      # the supplement hash and build a DirectivesSupplement, the plain
      # fields build the base document, and the pair lands on a
      # BundledIdentifier.
      def build_bundled(hash, all_parts)
        bundle_keys = BUNDLE_PREFIXES.flat_map do |prefix|
          hash.keys.select { |key| key.to_s.start_with?(prefix) }
        end
        supplements = BUNDLE_PREFIXES.filter_map do |prefix|
          keys = hash.keys.select { |key| key.to_s.start_with?(prefix) }
          next if keys.empty?

          build(rekey_prefix(hash.slice(*keys), prefix))
        end
        identifier = BundledIdentifier.new
        identifier.base_document = build(hash.except(*bundle_keys))
        identifier.supplements = supplements
        all_parts ? identifier.to_all_parts : identifier
      end

      # Strip a layer prefix from every key ("supp_" / "supp2_" /
      # "supp3_" / "isor_supp_" / "dsupp_").
      def rekey_prefix(hash, prefix)
        hash.to_h do |key, value|
          [key.to_s.delete_prefix(prefix).to_sym, value]
        end
      end

      def rekey(hash, map)
        hash.to_h { |key, value| [map[key], value] }
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

      # ISO normalizes em/en dashes, slashes, and spaces to hyphens so that
      # "4037/1979", "4037-1979", and "ISO/IEC DIR 1 IEC" all split cleanly.
      def normalize_number_with_part(value)
        value.to_s
          .tr("#{Parser::DASH_CHARS.join}/", "-")
          .gsub(" ", "-")
      end

      # LEGACY: "ISO 4037-1979" used a hyphen where the modern form is
      # "ISO 4037:1979". When the part looks like a 4-digit year in a
      # plausible range, treat it as a date instead of a part number.
      def extract_legacy_year(number, part, code_class)
        return nil unless part&.match?(/^\d{4}$/)

        year_value = part.to_i
        return nil unless year_value.between?(1900, 2099)

        {
          number: number,
          date: ::Pubid::Components::Date.new(year: part),
        }
      end

      def cast(type, value)
        case type
        when :base
          # If it has a base identifier, we need to build a supplement
          # We assume that the base identifier is already a valid Identifier object
          build(value)

          # If there is a base, and it has a joint_identifier, we need to use a CombinedIdentifier.

        when :publisher, :directives_supplement_body, :supplement_publisher
          # value can be either a string OR a hash with publisher + copublisher
          if value.is_a?(Hash)
            Pubid::Iso::Components::Publisher.new(
              publisher: value[:publisher],
              copublisher: value[:copublisher],
            )
          else
            # Default copublisher to [] (not nil) so a bare-string publisher
            # (e.g. a TC document, which skips the copublisher merge) matches
            # the [] convention used by copublisher-merged parses and by
            # Identifier.create. Otherwise equality fails on [] vs nil.
            Pubid::Iso::Components::Publisher.new(publisher: value,
                                                  copublisher: [])
          end

        when :copublishers
          # Copublishers already merged into publisher
          # Create array of Publisher objects for identifier.copublishers attribute
          if value.nil? || value.empty?
            nil
          else
            value.map do |copublisher|
              Pubid::Iso::Components::Publisher.new(publisher: copublisher[:copublisher])
            end
          end

        when :year
          # For TC documents, parser returns :year but identifier uses :date
          # Return as date for assignment
          { date: Pubid::Components::Date.new(year: value.to_s) }

        when :number_with_part
          # "1234" (no part)
          # or "1234-1" ('1' is part)
          # or "1234-1-2" ('1' is part, '2' is subpart)
          # or "29110-5-1-1" ('5' is part, '1-1' is subpart)
          # or "105/F" ('F' is part)
          # or "5843/6" ('6' is part)
          # LEGACY: "4037-1979" (number-year, year should become date)
          parse_number_with_part(value)

        when :directives_type
          # nothing to do here, just return nil
          nil

        when :type_with_stage
          # "WD"
          # "PAS"
          # "CD TR"
          original_value = value.to_s # Store the original parsed value
          iteration = original_value.match(/(\d+)$/)
          normalized_value = original_value.sub(iteration.to_s, "")
          typed_stage = locate_typed_stage(normalized_value || "")

          # Create a copy with the original abbreviation preserved
          typed_stage_with_original = typed_stage.dup
          typed_stage_with_original.original_abbr = original_value.strip

          ##
          # Always use TypedStage in an Identifier or separate Type and Stage.
          {
            stage: typed_stage_with_original.to_stage,
            type: typed_stage_with_original.to_type,
            typed_stage: typed_stage_with_original,
          }
        when :stage_iteration
          # "1" or "2"
          Pubid::Components::Iteration.new(number: value.to_s)

        when :date
          parse_date(value)

        when :undated_marker
          # ISO/IEC undated reference (e.g. "ISO 16634:--") — explicit
          # publication-date slot with no year; round-trips via date.render.
          { date: Pubid::Components::Date.new(undated: true) }

        when :edition
          # value can be "Ed.2", "Ed 2", "ED1", "Edition 13", or just "Ed"
          original_text = value.to_s
          # Extract just the digit(s) for the number field
          number_string = original_text.match(/\d+/)&.to_s
          # A plain string: Components::Edition#number is typed Value, so a
          # component here would leak a live Ruby object into to_hash (and a
          # !ruby/object tag into to_yaml).
          Pubid::Components::Edition.new(number: number_string,
                                         original_text: original_text)

        when :languages
          parse_languages(value)

        when :all_parts
          # Set all_parts boolean attribute directly on identifier
          true

        # ISO 4214:2022 | IDF/RM 254:2022
        when :joint_identifier
          case value[:publisher]
          when "IDF"
            Pubid::Idf.build_from_parse(value)
          end

        when :subgroup
          # Handle JTC 1 subgroup in directives (ISO/IEC JTC 1 DIR)
          value.to_s

        when :supplements
          # Handle bundled supplements (+ operator)
          # Each supplement is a hash that needs to be built
          value.map { |supplement_hash| build(supplement_hash) }

        when :base_document
          # For bundled identifiers, build the base document
          build(value)

        # TC Document attributes
        when :tc_type, :sc_type, :wg_type
          value.to_s

        when :tc_number, :sc_number, :wg_number
          value.to_s

        when :number
          # For TC documents, number is the document number (N number)
          # For regular identifiers, this is handled in :number_with_part
          if value.is_a?(String) ||
              value.is_a?(Integer)
            value.to_s
          else
            value
          end

        when :supplement_version
          # The RFC 5141 <supplversion> carried on supplement identifiers
          value.to_s

        when :stage
          # Raw stage code from URN parser (e.g., "10.00", "50.00")
          # Convert to type_with_stage format for builder
          # Look up the typed stage from stage code
          typed_stage = Pubid::Iso.locate_stage_by_stage_code(value.to_s)
          if typed_stage
            typed_stage.abbr.is_a?(Array) ? typed_stage.abbr.first : typed_stage.abbr
          else
            # Fallback: return the raw stage code (shouldn't happen with valid data)
            value.to_s
          end

        else
          raise ArgumentError, "Unknown parameter type: #{type}"
        end
      end
    end
  end
end

Pubid::Iso::Builder.prepend(Pubid::Builder::AllPartsWrap)
