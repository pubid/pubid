# frozen_string_literal: true

require_relative "base"

module PubidNew
  module Etsi
    module Identifiers
      # Base class for ETSI supplements (Amendment, Corrigendum)
      class SupplementIdentifier < Base
        attribute :base, PubidNew::Etsi::Identifiers::Base
        attribute :number, :integer

        def initialize(base:, number:)
          @base = base
          @number = number
        end

        # Inherit attributes from base
        def type
          base.type
        end

        def code
          base.code
        end

        def version
          base.version
        end

        def date
          base.date
        end

        # Render as: ETSI TYPE CODE/SUPPLEMENT VERSION (DATE)
        def to_s
          "#{base.publisher} #{base.type} #{base.code}/#{supplement_notation} #{base.version} (#{base.date.year}-#{base.date.month.to_s.rjust(2, '0')})"
        end

        def supplement_notation
          raise NotImplementedError
        end

        def ==(other)
          return false unless other.is_a?(SupplementIdentifier)
          return false unless other.class == self.class

          base == other.base && number == other.number
        end
      end
    end
  end
end