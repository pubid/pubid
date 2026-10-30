# frozen_string_literal: true

module Pubid
  module Calconnect
    # Grammar for CalConnect identifiers.
    #
    # Shape: CC[/<series>] <number>:<date>
    #   CC 18011:2018
    #   CC/DIR 10006:2019
    #   CC/Adv 0707.1:2007        (dot sub-part)
    #   CC/A 0812-1:2008          (dash sub-part)
    #   CC/WD 51017:2024-07-23    (full ISO date)
    class Parser
    end
  end
end
