# frozen_string_literal: true

module Pubid
  module Csa
    class Scheme < Pubid::Scheme
      class << self
        def identifiers
          @identifiers ||= [
            Identifiers::Standard,
            Identifiers::Bundled,
            Identifiers::CanadianAdopted,
            Identifiers::CsaAdopted,
            Identifiers::Package,
            Identifiers::Series,
            Identifiers::Cec,
            Identifiers::Combined,
          ].freeze
        end

        def supplement_identifiers
          @supplement_identifiers ||= [].freeze
        end

        def typed_stages
          @typed_stages ||= [].freeze
        end

        def supplement_typed_stages
          @supplement_typed_stages ||= [].freeze
        end

        def locate_typed_stage_by_abbr(_abbr)
          raise ArgumentError,
                "CSA identifiers do not use typed stages"
        end

        def locate_identifier_klass_by_type_code(_type_code)
          raise ArgumentError,
                "CSA identifiers do not use type codes"
        end
      end
    end
  end
end
