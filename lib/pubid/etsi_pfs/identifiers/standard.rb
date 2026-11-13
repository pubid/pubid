module Pubid
  module EtsiPfs
    module Identifiers
      # Concrete ETSI Standard identifier type (PFS type `standard`).
      class Standard < Identifier
          TYPED_STAGES = [].freeze

      attribute :type, :string
      attribute :number, :string
      attribute :minor, :string
      attribute :parts, :string, collection: true, initialize_empty: true
      attribute :version, :string
      attribute :year, :string
      attribute :month, :string
      attribute :is_edition, :boolean, default: -> { false }

        key_value do
          map "_type", to: :_type
          map "type", to: :type
          map "number", to: :number
          map "minor", to: :minor
          map "parts", to: :parts
          map "version", to: :version
          map "year", to: :year
          map "month", to: :month
          map "is_edition", to: :is_edition
        end

        def self.type
          { key: :etsi, web: :etsi, title: "ETSI Standard", short: "ETSI" }
        end

        # The scheme-canonical wire tag declared in the definition:
        # to_hash stays byte-identical with the scheme's coded
        # flavor, and this flavor's own from_hash routes the tag
        # to this class.
        def self.polymorphic_name
          "pubid:etsi:etsi-standard"
        end

        def mr_type
          mr_sanitize(type)
        end

        def mr_number_with_part
          mr_sanitize([number, minor, *Array(parts)].compact.join("-"))
        end

        def mr_year
          mr_sanitize([year, month].compact.join("-"))
        end

        def mr_edition
          mr_sanitize(version)
        end

        # The MR charset rule (the coded flavors' mr_sanitize):
        # lowercase, [a-z0-9-], non-charset runs collapsed to one
        # dash; empty answers nil so the joined slug never gains a
        # blank segment.
        def mr_sanitize(value)
          return nil if value.nil? || value.to_s.empty?

          sanitized = value.to_s.downcase
            .gsub(/[^a-z0-9-]+/, "-").gsub(/\A-+|-+\z/, "")
          sanitized.empty? ? nil : sanitized
        end
      end
    end
  end
end
