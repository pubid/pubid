# frozen_string_literal: true

module Pubid
  module CenCenelec
    autoload :Builder, "#{__dir__}/cen_cenelec/builder"
    autoload :Identifier, "#{__dir__}/cen_cenelec/identifier"
    autoload :Identifiers, "#{__dir__}/cen_cenelec/identifiers"
    autoload :Parser, "#{__dir__}/cen_cenelec/parser"
    autoload :Scheme, "#{__dir__}/cen_cenelec/scheme"
    autoload :SingleIdentifier, "#{__dir__}/cen_cenelec/single_identifier"
    autoload :SupplementIdentifier,
             "#{__dir__}/cen_cenelec/supplement_identifier"
    autoload :UrnGenerator, "#{__dir__}/cen_cenelec/urn_generator"

    def self.parse(identifier)
      CenCenelec::Identifier.parse(identifier)
    end
  end
end

Pubid::Registry.register(:cen_cenelec, Pubid::CenCenelec)
