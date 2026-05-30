# frozen_string_literal: true

module Pubid
  module Nist
    module Identifiers
      # Base NIST/NBS identifier class
      # Each series type inherits from this and overrides series_code
      class Base < Pubid::Identifier
        # Default: no typed stages. Subclasses override as needed.
        def self.typed_stages
          []
        end

        # Generate URN for this identifier
        #
        # @return [String] URN representation

        attribute :publisher, Components::Publisher
        attribute :series, Components::Code # Set by Builder from parsed data
        attribute :number, Components::Code

        # V2 COMPONENTS (Lutaml::Model objects) - PROPER SEPARATION
        attribute :edition, Components::Edition # Edition (type + id): e2, e2021, r5, -3
        attribute :edition_component, Components::Edition # V2 edition component (alias)
        attribute :volume, Components::Volume # Volume component (v6)
        attribute :part, Components::Part  # Part component (n1 or pt1)
        attribute :stage, Components::Stage
        attribute :version_component, Components::Version
        attribute :update_component, Components::Update
        attribute :translation_component, Components::Translation
        attribute :issue_number, Components::IssueNumber
        attribute :parsed_format, :string  # :mr, :short, :long, :abbrev
        attribute :publisher_was_parsed, :boolean, default: -> { false }

        # LEGACY attributes (keep for backward compatibility during migration)
        attribute :parts, Components::Code, collection: true
        attribute :revision, :string
        attribute :revision_year, :string # Year for revision (e.g., r6/1925, r1963, rJun1992)
        attribute :revision_month, :string # Month for revision (e.g., rJun1992)
        attribute :edition_year, :string # Legacy edition year for backward compatibility
        attribute :version, :string
        attribute :update, Components::Update
        attribute :year, :integer
        attribute :month, :integer

        # Additional attributes for complex patterns
        attribute :first_number, Components::Code
        attribute :second_number, Components::Code
        attribute :update_number, :string
        attribute :update_year, :string
        attribute :addendum, :string
        attribute :addendum_number, :string
        attribute :supplement, :string
        attribute :supplement_date_range_start, :string # For date ranges like Jan1924-Jan1926
        attribute :supplement_date_range_end, :string
        attribute :supplement_has_revision, :boolean, default: -> { false }
        attribute :errata, :string
        attribute :index, :string
        attribute :insert, :string
        attribute :section, :string
        attribute :appendix, :string
        attribute :translation, :string
        attribute :draft, :string
        attribute :draft_number, :string # For -draft N → N pd rendering

        # Default series_code — subclasses override to provide a normalized series name.
        def series_code
          nil
        end

        def initialize(**attributes)
          super()

          attrs = self.class.attributes
          attributes.each do |key, value|
            next if value.nil?

            setter = :"#{key}="
            public_send(setter, value) if attrs.key?(key)
          end

          # NOTE: Compound number building is handled by the Builder class
          # Do NOT build compound numbers here - let the builder apply special patterns first
          # See lib/pubid/nist/builder.rb lines 368-472 for compound number logic
        end

        # Attributes that are build artifacts or rendering aliases, not part
        # of an identifier's logical identity. They diverge between equally-
        # valid spellings of the same id (e.g. long "Rev. 1" vs short "r1"):
        #   - edition_component: redundant alias of :edition
        #   - first_number/second_number: decomposed parts of the canonical
        #     :number, retained from the parse for building
        #   - parsed_format: records the input format for round-trip rendering
        EQUALITY_IGNORED_ATTRS = %i[
          edition_component first_number second_number parsed_format
        ].freeze

        # Logical identity comparison: equal when every attribute except the
        # build artifacts/aliases above matches. (Edition#== already ignores
        # its rendering-only original_prefix.)
        def ==(other)
          return false unless other.instance_of?(self.class)

          self.class.attributes.each_key.all? do |name|
            EQUALITY_IGNORED_ATTRS.include?(name) || send(name) == other.send(name)
          end
        end

        alias eql? ==

        def hash
          vals = self.class.attributes.each_key.reject do |name|
            EQUALITY_IGNORED_ATTRS.include?(name)
          end.map { |name| send(name) }
          [self.class, *vals].hash
        end

        # Return a copy with the named attributes nil'd. Overrides
        # Pubid::Identifier#exclude because NIST's initialize is keyword-only
        # (initialize(**attributes)) while the inherited exclude rebuilds via
        # the positional self.class.new(attrs) form — passing a positional
        # hash to a keyword-only initializer raises ArgumentError. Rebuild
        # with the keyword splat instead.
        def exclude(*args)
          excluded_args = args.dup
          excluded_args << :date if excluded_args.delete(:year)

          attrs = self.class.attributes.each_with_object({}) do |(name, _), h|
            h[name] = excluded_args.include?(name) ? nil : send(name)
          end
          self.class.new(**attrs)
        end

        # Compute revision from edition component for backward compatibility
        # @return [String, nil] revision string (e.g., "r5") or nil
        def revision
          return @revision if @revision

          # Compute from edition component if available
          if edition&.type && edition.id
            "#{edition.type}#{edition.id}"
          end
        end

        # Backward compatibility: translation method returns translation_component
        # This allows tests to use parsed.translation.language instead of parsed.translation_component.language
        def translation
          translation_component
        end

        # Backward compatibility: language method returns translation_component
        # This allows tests to use parsed.language instead of parsed.translation_component
        def language
          translation_component
        end

        # Generate identifier string in specified format
        # @param format [:full, :long, :abbreviated, :short, :mr] output format
        def to_s(format = nil)
          # Handle both keyword argument (hash) and positional argument (symbol/string)
          format = format[:format] if format.is_a?(Hash)

          # Default to parsed_format if available (preserves input format on round-trip)
          # Falls back to :short format for output (normalization)
          # Explicit format parameter always overrides parsed_format
          effective_format = format || parsed_format&.to_sym || :short
          effective_format = effective_format.to_sym if effective_format.is_a?(String)
          case effective_format
          when :full, :long
            to_full_style
          when :abbreviated, :abbrev
            to_abbreviated_style
          when :short
            to_short_style
          when :mr
            to_mr_style
          else
            to_short_style
          end
        end

        # Returns weight based on amount of defined attributes
        # Used for ranking identifiers by specificity for conflict resolution
        # @return [Integer] weight score (higher = more specific)
        def weight
          self.class.attributes.keys.inject(0) do |sum, key|
            val = public_send(key)
            val && !val.to_s.empty? ? sum + 1 : sum
          end
        end

        # Merge another document into this one
        # Used for combining document data, preferring more specific values
        # @param document [Base] another NIST document to merge
        # @return [Base] self with merged attributes
        def merge(document)
          return self unless document.is_a?(Base)

          attrs = self.class.attributes
          attrs.each_key do |var_name|
            next if var_name == :rendering_style
            next if var_name == :parsed_format

            current_val = public_send(var_name)
            new_val = document.public_send(var_name)
            next unless new_val

            should_merge = case var_name
                           when :publisher, :series, :number
                             true
                           when :edition
                             current_val.nil? || edition_greater?(new_val,
                                                                  current_val)
                           when :volume, :part, :version, :revision
                             current_val.nil? || (new_val.to_s.length > current_val.to_s.length)
                           when :supplement, :errata, :index, :insert, :section, :appendix, :translation
                             true
                           when :year, :month, :update, :draft
                             true
                           else
                             false
                           end

            public_send(:"#{var_name}=", new_val) if should_merge
          end

          self
        end

        # Helper to compare edition values numerically
        # @return [Boolean] true if edition1 is greater than edition2
        def edition_greater?(edition1, edition2)
          num1 = extract_edition_number(edition1)
          num2 = extract_edition_number(edition2)
          num1 && num2 && num1 > num2
        end

        # Extract numeric value from edition (r3 -> 3, r5 -> 5, e2 -> 2)
        # @return [Integer, nil] the edition number or nil if not extractable
        def extract_edition_number(edition)
          # Handle both String and Edition component
          edition_str = edition.to_s
          # Match patterns like r3, r5, e2, etc.
          match = edition_str.match(/^[er]?(\d+)$/)
          match ? match[1].to_i : nil
        end

        private

        def to_full_style
          # "National Institute of Standards and Technology Special Publication 800-27, Revision A"
          result = publisher_full_name
          result += " #{series_full_name}" if series
          result += " #{number.value}" if number
          result += parts.map { |p| "-#{p}" }.join if parts&.any?

          # Render volume and issue number in long form: "Vol. 6, No. 12"
          if volume && issue_number
            result += " Vol. #{volume}, #{issue_number.to_s(:long)}"
          elsif volume
            result += " Vol. #{volume}"
          end

          # NEW: Use edition component properly
          result += " #{edition.to_s(:long)}" if edition

          result += ", Revision #{revision.sub(/^r/, '')}" if revision

          # V2: Use version_component
          result += " #{version_component.to_s(:long)}" if version_component

          # V2: Use update_component
          result += " #{update_component.to_s(:long)}" if update_component

          # V2: Use stage
          result += " #{stage.to_s(:long)}" if stage

          # V2: Use translation_component (already includes space)
          result += translation_component.to_s(:long) if translation_component

          result
        end

        def to_abbreviated_style
          # "Natl. Inst. Stand. Technol. Spec. Publ. 800-57 Part 1, Revision 4"
          result = publisher_abbreviated_name
          result += " #{series_abbreviated_name}" if series
          result += " #{number}" if number
          result += " Part #{parts.first}" if parts&.any?

          # NEW: Use edition component properly
          result += " #{edition.to_s(:abbrev)}" if edition

          result += ", Revision #{revision}" if revision

          # V2: Use version_component
          result += " #{version_component.to_s(:abbrev)}" if version_component

          # V2: Use update_component
          result += " #{update_component.to_s(:abbrev)}" if update_component

          # V2: Use stage
          result += " #{stage.to_s(:abbrev)}" if stage

          # V2: Use translation_component
          result += ", #{translation_component.to_s(:abbrev)}" if translation_component

          result
        end

        def to_short_style
          # "SP 800-187" or "NIST SP 800-187" - handle compound series properly
          result = ""

          # Determine effective publisher
          # Only show publisher if it was explicitly parsed (either directly or from series prefix)
          effective_publisher = if publisher && publisher_was_parsed
                                  # Publisher was in input (either as separate field or extracted from "NBS CS" series)
                                  publisher.to_s
                                else
                                  # No publisher in input, don't show default
                                  nil
                                end

          # Determine effective series - PREFER series_code if subclass defines it
          # This allows normalization (e.g., LCIRC → LC in LetterCircular)
          effective_series = if series_code
                               series_code
                             elsif series
                               series.to_s
                             end

          # Special handling for compound series that include publisher prefix
          # If series starts with "NBS " (like "NBS CIRC"), use it as-is
          if effective_series&.start_with?("NBS ")
            result += effective_series
          elsif effective_publisher && effective_series
            result += "#{effective_publisher} #{effective_series}"
          elsif effective_series && publisher_was_parsed
            # Only add "NIST" prefix if publisher was explicitly in the input
            result += "NIST #{effective_series}"
          elsif effective_series
            # No publisher in input, just show series without prefix
            result += effective_series
          end

          result += " #{number}" if number
          result += parts.map { |p| "-#{p}" }.join if parts&.any?

          # NEW: Use Volume and Part components (v6n1 notation for CSM, pt1 for SP)
          if volume.is_a?(Components::Volume) && part.is_a?(Components::Part)
            # CSM series: v#n# notation
            result += " #{volume}#{part}"
          elsif part.is_a?(Components::Part)
            # SP and other series: use Part.type to determine format
            result += part.to_s
          # Legacy: Render standalone volume (not part of v#n#)
          elsif volume && !issue_number && !part
            vol_str = volume.is_a?(Components::Volume) ? volume.to_s : "v#{volume}"
            result += vol_str
          elsif volume && issue_number
            # Render volume and issue number in short form: "v6n12"
            vol_str = volume.is_a?(Components::Volume) ? volume.to_s : "v#{volume}"
            result += "#{vol_str}n#{issue_number.number}"
          end

          # NEW: Use edition component properly (e2, e2021, r5, -3)
          # NO space before edition when number present (per NIST spec)
          # Only add space for bare edition (no number case) or if original_prefix has specific format
          if edition
            if edition.original_prefix && !edition.original_prefix.empty?
              # original_prefix includes the full prefix (e.g., " Rev. " for verbose format)
              result += edition.to_s
            elsif number
              # Number present, NO space: "800-53r5"
              result += edition.to_s
            else
              # Bare edition, add space: " r5"
              result += " #{edition}"
            end
          end

          # V2: Use version_component if available, else use version string.
          # Attach directly (no leading space) to match edition rendering
          # (e.g. "800-53r5"), so version reads "800-45ver2" not
          # "800-45 ver2".
          if version_component
            result += version_component.to_s(:short)
          elsif version
            result += "ver#{version}"
          end

          # Add supplement. NIST/NBS canonical short form is single-p "sup"
          # with the suffix attached directly, no dash (relaton-data-nist
          # uses "sup2", "sup1940", "supA"); date-range keeps its inner dash.
          if supplement_date_range_start && supplement_date_range_end
            result += "sup#{supplement_date_range_start}-#{supplement_date_range_end}"
          elsif supplement_has_revision
            result += "suprev"
          elsif supplement && !supplement.empty?
            result += "sup#{supplement}"
          elsif supplement
            result += "sup"
          end

          # Add other attributes
          result += errata.to_s if errata
          result += "index" if index
          result += "insert" if insert
          result += "sec#{section}" if section
          result += "app" if appendix

          # Add addendum - render as " Add." suffix
          if addendum || addendum_number
            result += " Add."
          end

          # V2: Use update_component if available, else use update string
          if update_component
            result += update_component.to_s(:short)
          elsif update
            result += "-upd#{update}"
          end

          # Add draft - render as {N}pd if draft_number present
          if draft_number
            result += " #{draft_number}pd"
          elsif draft&.to_s&.include?("draft") && !draft.to_s.include?("Draft)")
            result += "-draft"
          end

          # V2: Add stage component (at end, before translation)
          if stage
            result += " #{stage.to_s(:short)}"
          end

          # V2: Use translation_component if available, else use translation string
          # Note: translation_component.to_s already includes the space prefix
          if translation_component
            result += translation_component.to_s(:short)
          elsif translation
            result += " #{translation}"
          end

          result
        end

        def to_mr_style
          # "NIST.SP.800-116r1.ipd" (machine-readable with dots)
          result = (publisher || "NIST").to_s

          # Determine effective series - PREFER series_code if subclass defines it
          # This allows normalization (e.g., LCIRC → LC in LetterCircular)
          effective_series = if series_code
                               series_code
                             elsif series
                               series.to_s
                             end

          result += ".#{effective_series}" if effective_series
          result += ".#{number}" if number
          result += parts.map { |p| "-#{p}" }.join if parts&.any?

          # Part component (pt1, v6n1, etc.)
          result += part.to_s if part.is_a?(Components::Part)

          # NEW: Use edition component - NO space before edition in MR format (per NIST spec)
          if edition
            # If edition has original_prefix set (e.g., verbose " Rev. "), use it as-is
            # Otherwise, no space needed in MR format: ".800-53r5"
            if edition.original_prefix && !edition.original_prefix.empty?
            end
            result += edition.to_s
          end

          # V2: Use version_component
          result += version_component.to_s(:mr) if version_component

          # V2: Use update_component
          result += update_component.to_s(:mr) if update_component

          # V2: Use stage
          result += ".#{stage.to_s(:mr)}" if stage

          # Add addendum - render as ".Add." suffix in MR format
          if addendum || addendum_number
            result += ".Add."
          end

          # V2: Use translation_component
          result += translation_component.to_s(:mr) if translation_component

          result
        end

        def series_full_name
          {
            "SP" => "Special Publication",
            "FIPS" => "Federal Information Processing Standards",
            "IR" => "Interagency Report",
            "TN" => "Technical Note",
          }[series] || series
        end

        def series_abbreviated_name
          {
            "SP" => "Spec. Publ.",
            "FIPS" => "Fed. Inf. Proc. Stand.",
            "IR" => "Interag. Rep.",
            "TN" => "Tech. Note",
          }[series&.to_s || series_code] || (series&.to_s || series_code)
        end

        def publisher_full_name
          case publisher.to_s
          when "NBS"
            "National Bureau of Standards"
          when "NIST"
            "National Institute of Standards and Technology"
          else
            publisher.to_s
          end
        end

        def publisher_abbreviated_name
          case publisher.to_s
          when "NBS"
            "Natl. Bur. Stand."
          when "NIST"
            "Natl. Inst. Stand. Technol."
          else
            publisher.to_s
          end
        end

        # Default publisher for series without explicit publisher
        # Subclasses can override
        def default_publisher
          "NIST"
        end
      end
    end
  end
end
