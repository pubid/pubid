# frozen_string_literal: true

module Pubid
  module Jcgm
    module Identifiers
      autoload :Amendment, "#{__dir__}/identifiers/amendment"
      autoload :Corrigendum, "#{__dir__}/identifiers/corrigendum"
      autoload :Guide, "#{__dir__}/identifiers/guide"
      autoload :GumGuide, "#{__dir__}/identifiers/gum_guide"
      autoload :Meeting, "#{__dir__}/identifiers/meeting"
    end
  end
end
