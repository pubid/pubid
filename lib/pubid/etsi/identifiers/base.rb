# frozen_string_literal: true

module Pubid
  module Etsi
    module Identifiers
      # Base class for all ETSI identifiers
      class Base < Lutaml::Model::Serializable

        # Generate URN for this identifier
        #
        # @return [String] URN representation
        attribute :type, :string
        attribute :code, Pubid::Etsi::Components::Code
        attribute :version, Pubid::Etsi::Components::Version
        attribute :date, Pubid::Components::Date

        def publisher
          "ETSI"
        end

        def to_s
          result = "#{publisher} #{type} #{code}"
          result += " #{version} (#{date.year}-#{date.month.to_s.rjust(2,
                                                                       '0')})"
          result
        end

        def ==(other)
          return false unless other.is_a?(Base)

          type == other.type &&
            code == other.code &&
            version == other.version &&
            date == other.date
        end
      end
    end
  end
end
