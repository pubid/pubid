# frozen_string_literal: true

require "lutaml/model"
require_relative "../components/publisher"
require_relative "../components/code"
require_relative "../components/stage"
require_relative "../components/edition"
require_relative "../components/version"
require_relative "../components/update"
require_relative "../components/translation"
require_relative "../components/issue_number"
require_relative "../components/volume"
require_relative "../components/part"

module PubidNew
  module Nist
    module Identifiers
      # Base NIST/NBS identifier class
      # Each series type inherits from this and overrides series_code
      class Base < Lutaml::Model::Serializable
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

        def initialize(**attributes)
          super()

          # Set all provided attributes
          attributes.each do |key, value|
            send("#{key}=", value) if respond_to?("#{key}=") && !value.nil?
          end

          # Build the number from first_number and second_number if present
          if first_number && !number
            self.number = first_number
            if second_number
              # Append second_number to create compound number
              compound_value = "#{first_number.value}-#{second_number.value}"
              self.number = Components::Code.new(number: compound_value)
            end
          end
        end

        # Generate identifier string in specified format
        # @param format [:full, :long, :abbreviated, :short, :mr] output format
        def to_s(format = :short)
          case format
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
          result += "#{translation_component.to_s(:long)}" if translation_component

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
          effective_publisher = publisher ? publisher.to_s : default_publisher

          # Determine effective series - PREFER series_code if subclass defines it
          # This allows normalization (e.g., LCIRC → LC in LetterCircular)
          effective_series = if respond_to?(:series_code) && series_code
                               series_code
                             elsif series
                               series.to_s
                             end

          # If we have a compound series that starts with NBS, use it as-is
          if effective_series && effective_series.start_with?("NBS")
            result += effective_series
          elsif effective_publisher && effective_series
            result += effective_publisher + " " + effective_series
          elsif effective_series
            result += "NIST " + effective_series
          end

          result += " #{number}" if number
          result += parts.map { |p| "-#{p}" }.join if parts&.any?

          # NEW: Use Volume and Part components (v6n1 notation for CSM, pt1 for SP)
          if volume.is_a?(Components::Volume) && part.is_a?(Components::Part)
            # CSM series: v#n# notation
            result += " #{volume}#{part}"
          elsif part.is_a?(Components::Part)
            # SP and other series: use Part.type to determine format
            result += "#{part}"
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
          # Add space before edition if no number (bare edition case like "e2")
          if edition
            result += (number ? "" : " ") + edition.to_s
          end

          # V2: Use version_component if available, else use version string
          if version_component
            result += " #{version_component.to_s(:short)}"
          elsif version
            result += " Ver. #{version}"
          end

          # Add supplement with date range support - FIX: proper spacing
          if supplement_date_range_start && supplement_date_range_end
            result += "supp#{supplement_date_range_start}-#{supplement_date_range_end}"
          elsif supplement_has_revision
            result += "supprev"
          elsif supplement && !supplement.empty?
            # Smart dash logic:
            # - If supplement starts with letter (month like "Jan1924"), NO dash
            # - If supplement is digits only (year like "1924"), WITH dash
            result += if supplement.match?(/^[A-Z]/)
                        "supp#{supplement}"
                      else
                        "supp-#{supplement}"
                      end
          elsif supplement
            result += "supp"
          end

          # Add other attributes
          result += "#{errata}" if errata
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
            result += "#{update_component.to_s(:short)}"
          elsif update
            result += "-upd#{update}"
          end

          # Add draft - render as {N}pd if draft_number present
          if draft_number
            result += " #{draft_number}pd"
          elsif draft && draft.to_s.include?("draft") && !draft.to_s.include?("Draft)")
            result += "-draft"
          end

          # V2: Add stage component (at end, before translation)
          if stage
            result += " #{stage.to_s(:short)}"
          end

          # V2: Use translation_component if available, else use translation string
          # Note: translation_component.to_s already includes the space prefix
          if translation_component
            result += "#{translation_component.to_s(:short)}"
          elsif translation
            result += " #{translation}"
          end

          result
        end

        def to_mr_style
          # "NIST.SP.800-116r1.ipd" (machine-readable with dots)
          result = (publisher || "NIST").to_s
          result += ".#{series}" if series
          result += ".#{number}" if number
          result += parts.map { |p| "-#{p}" }.join if parts&.any?

          # NEW: Use edition component
          result += edition.to_s if edition

          # V2: Use version_component
          result += "#{version_component.to_s(:mr)}" if version_component

          # V2: Use update_component
          result += "#{update_component.to_s(:mr)}" if update_component

          # V2: Use stage
          result += ".#{stage.to_s(:mr)}" if stage

          # V2: Use translation_component
          result += "#{translation_component.to_s(:mr)}" if translation_component

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
