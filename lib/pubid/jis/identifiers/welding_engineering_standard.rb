# frozen_string_literal: true

module Pubid
  module Jis
    module Identifiers
      # Japan Welding Engineering Society standard. JSA sells WES next to JIS,
      # so it parses through the JIS flavor, but the id carries no series
      # letter and no JIS prefix.
      # Examples: WES 7700-1:2019, WES 7301:2020R, WES 1112(E):2022
      class WeldingEngineeringStandard < SingleIdentifier
        PUBLISHER = "WES"
        # The type token after the WES root: "TR", "TS", or nil.
        WES_TYPE = nil

        # The WES class for a type token ("TR", "TS" or nil).
        def self.class_for_type(type)
          case type
          when "TR" then WeldingEngineeringTechnicalReport
          when "TS" then WeldingEngineeringTechnicalSpecification
          else WeldingEngineeringStandard
          end
        end

        def type_prefix
          nil
        end

        # "WES" is the root of the designation, not a publisher token, so
        # `to_s(with_publisher: false)` keeps it.
        def publisher_prefix
          nil
        end

        def wes_type
          self.class::WES_TYPE
        end

        def code
          result = [PUBLISHER, wes_type, number].compact.join(" ")
          result += parts.map { |p| "-#{p}" }.join if parts&.any?
          result
        end

        def mr_publisher
          PUBLISHER.downcase
        end

        def mr_type
          wes_type&.downcase
        end
      end
    end
  end
end
