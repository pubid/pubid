# frozen_string_literal: true

require "spec_helper"

# The renderer prints "Addendum" + (" No.")? + two spaces before the
# number; the printed form must parse back (write-only renders broke
# 22 corpus rows).
RSpec.describe Pubid::Bsi::Identifiers::AddendumDocument do
  [
    "BS 1902-2.3:Addendum No.  1:1976",
    "BS 449-2:1969 Addendum No.  1:1975",
    "BS 2000-0:Addendum  1:1983",
    "BS 6034:1981:Addendum No.  1:1986",
  ].each do |ref|
    it "round-trips #{ref.inspect}" do
      expect(described_class.parse(ref).to_s).to eq(ref)
    end
  end
end
