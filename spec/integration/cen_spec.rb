# frozen_string_literal: true

require "spec_helper"
require_relative "../../lib/pubid/cen"

RSpec.describe "CEN Integration Tests" do
  test_cases = [
    # Basic EN standards
    ["EN 1177:2008"],

    # CEN with types
    ["CEN/TS 14972"],

    # CLC with types
    ["CLC/TR 62125:2008"],

    # CEN/CLC combined
    ["CEN/CLC/TR 17602-80-12:2021"],
    ["CEN/CLC Guide 25:2023"],
    ["CEN-CLC Guide 32:2016", "CEN/CLC Guide 32:2016"],

    # CLC GUIDE normalization
    ["CLC GUIDE 1:2022", "CLC Guide 1:2022"],

    # Stages
    ["prEN 12464-1:2019"],
    ["FprEN 16114:2011"],

    # Amendments
    ["EN 60335-1:2012/A2:2019"],
    ["EN 196-3:2005+A1:2008"],

    # Corrigenda
    ["EN 196-3:2005+AC1:2008"],
    ["EN 10077-1:2006+AC:2009+AC2:2009"],

    # CWA/HD
    ["CWA 95000:2019"],
    ["HD 1000:1988"],

    # Adopted standards
    ["EN ISO 13485:2012"],
    ["EN ISO/IEC 80079-34:2020"],
    ["EN IEC 62368-1:2020"],
  ]

  test_cases.each do |test_input, expected_output|
    expected_output ||= test_input

    context "when parsing '#{test_input}'" do
      it "round-trips correctly to '#{expected_output}'" do
        parsed = Pubid::Cen.parse(test_input)
        expect(parsed.to_s).to eq(expected_output)
      end
    end
  end
end
