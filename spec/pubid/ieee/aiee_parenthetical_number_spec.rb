# frozen_string_literal: true

require "spec_helper"

# Regression for issue #32: an AIEE number with a parenthetical alternate
# number (e.g. "431 (105)") leaked its raw Parslet subtree into `to_s`
# (`AIEE No {main_number: "431"@8, parenthetical: ...}-1958`).
RSpec.describe "IEEE AIEE parenthetical number (issue #32)" do
  let(:parsed) { Pubid::Ieee.parse("AIEE No 431 (105) -1958") }

  it "does not leak the raw parse tree into to_s" do
    expect(parsed.to_s).not_to include("main_number")
    expect(parsed.to_s).not_to match(/@\d+/)
  end

  it "preserves the main and alternate numbers" do
    expect(parsed.to_s).to include("431 (105)")
  end
end
