# frozen_string_literal: true

module Pubid
  module Iho
    module Identifiers
      autoload :Bathymetric,     "#{__dir__}/identifiers/bathymetric"
      autoload :CapacityBuilding, "#{__dir__}/identifiers/capacity_building"
      autoload :Miscellaneous,  "#{__dir__}/identifiers/miscellaneous"
      autoload :Publication,    "#{__dir__}/identifiers/publication"
      autoload :Standard,       "#{__dir__}/identifiers/standard"
    end
  end
end
