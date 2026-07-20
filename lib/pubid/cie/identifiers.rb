# frozen_string_literal: true

module Pubid
  module Cie
    module Identifiers
      autoload :CodeAttributes, "#{__dir__}/identifiers/code_attributes"
      autoload :Bundle, "#{__dir__}/identifiers/bundle"
      autoload :Conference, "#{__dir__}/identifiers/conference"
      autoload :Corrigendum, "#{__dir__}/identifiers/corrigendum"
      autoload :DualPublished, "#{__dir__}/identifiers/dual_published"
      autoload :Identical, "#{__dir__}/identifiers/identical"
      autoload :JointPublished, "#{__dir__}/identifiers/joint_published"
      autoload :Proceedings, "#{__dir__}/identifiers/proceedings"
      autoload :Standard, "#{__dir__}/identifiers/standard"
      autoload :Supplement, "#{__dir__}/identifiers/supplement"
      autoload :TutorialBundle, "#{__dir__}/identifiers/tutorial_bundle"
    end
  end
end
