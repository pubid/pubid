# frozen_string_literal: true

module Pubid
  module Jis
    module Identifiers
      # Japan Welding Engineering Society standard. JSA sells WES next to JIS,
      # so it parses through the JIS flavor, but the id carries no series
      # letter and no JIS prefix.
      # Examples: WES 7700-1:2019, WES 7301:2020R
      class WeldingEngineeringStandard < SingleIdentifier
        PUBLISHER = "WES"

        def type_prefix
          nil
        end

        # "WES" is the root of the designation, not a publisher token, so
        # `to_s(with_publisher: false)` keeps it.
        def publisher_prefix
          nil
        end

        def code
          result = "#{PUBLISHER} #{number}"
          result += parts.map { |p| "-#{p}" }.join if parts&.any?
          result
        end

        def mr_publisher
          PUBLISHER.downcase
        end
      end
    end
  end
end
