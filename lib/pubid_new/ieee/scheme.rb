# frozen_string_literal: true

require "lutaml/model"

module PubidNew
  module Ieee
    # Scheme class representing an IEEE identifier structure
    # Single Responsibility: Data model for IEEE identifiers
    class Scheme < Lutaml::Model::Serializable
      attribute :publisher, :string, default: -> { "IEEE" }
      attribute :copublishers, :string, collection: true, default: -> { [] }
      attribute :type, :string, default: -> { nil }
      attribute :draft_status, :string, default: -> { nil }
      attribute :number, :string
      attribute :part, :string, default: -> { nil }
      attribute :subpart, :string, default: -> { nil }
      attribute :year, :string, default: -> { nil }
      attribute :month, :string, default: -> { nil }
      attribute :day, :string, default: -> { nil }
      attribute :edition, :string, default: -> { nil }
      attribute :draft, :string, default: -> { nil }
      attribute :draft_version, :string, default: -> { nil }
      attribute :revision, :string, default: -> { nil }
      attribute :corrigendum, :string, default: -> { nil }
      attribute :cor_number, :string, default: -> { nil }
      attribute :cor_year, :string, default: -> { nil }
      attribute :amendment, :string, default: -> { nil }
      attribute :amd_number, :string, default: -> { nil }
      attribute :amd_year, :string, default: -> { nil }
      attribute :reaffirmed, :string, default: -> { nil }
      attribute :redline, :boolean, default: -> { false }
      attribute :revision_of, :string, default: -> { nil }
      attribute :amendment_to, :string, default: -> { nil }
      attribute :adoption, :string, default: -> { nil }
      attribute :note, :string, default: -> { nil }

      # Convert to string representation
      # @return [String] the identifier string
      def to_s
        parts = []

        # Publisher(s)
        if publisher
          pub_str = publisher
          if copublishers && !copublishers.empty?
            pub_str += "/" + copublishers.join("/")
          end
          parts << pub_str
        end

        # Type and draft status
        if draft_status
          parts << draft_status.strip
        end
        
        if type
          # Preserve the exact type as parsed
          parts << type.to_s
        end

        # Number
        parts << number

        result = parts.join(" ")

        # Part/subpart
        result += ".#{part}" if part
        result += ".#{subpart}" if subpart

        # Year
        result += "-#{year}" if year && !month

        # Corrigendum
        if corrigendum || cor_number
          result += "/Cor #{cor_number || '1'}"
          result += "-#{cor_year}" if cor_year
        end

        # Amendment
        if amendment || amd_number
          result += "/Amd#{amd_number || '1'}"
          result += "-#{amd_year}" if amd_year
        end

        # Draft
        if draft_version
          result += "/D#{draft_version}"
          result += ".#{revision}" if revision
        elsif draft
          result += "/D#{draft}"
          result += ".#{revision}" if revision
        end

        # Month and year (publication date)
        if month
          result += ", #{month} #{year}"
        end

        # Edition
        if edition
          result += ", #{year} Edition" if year && !month
          # Or "Edition X.Y - YYYY" format
        end

        # Additional parameters
        params = []
        params << "Reaffirmed #{reaffirmed}" if reaffirmed
        params << "Revision of IEEE Std #{revision_of}" if revision_of
        params << "Amendment to IEEE Std #{amendment_to}" if amendment_to
        params << "Adoption of #{adoption}" if adoption
        params << note if note

        result += " (#{params.join(', ')})" if params.any?

        # Redline
        result += " - Redline" if redline

        result
      end
    end
  end
end