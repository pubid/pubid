# frozen_string_literal: true

require "spec_helper"

RSpec.describe "IEC-led dual-form identifier — issue #202" do
  # The form
  #   IEC 60076-21:2011 Edition 1.0 2011-12 IEEE Std C57.15
  # is an IEC-led dual publication (IEC is lead, IEEE is co-publisher).
  # The IEEE parser's IEC-led branch accepts "Edition N.M YYYY-MM" but
  # not when the IEC number carries a colon-year suffix (":YYYY"). The
  # pre-parser now strips the redundant ":YYYY" — the year is preserved
  # in the Edition clause — so the existing dual-form parser handles it.

  it "parses 'IEC 60076-21:2011 Edition 1.0 2011-12 IEEE Std C57.15'" do
    parsed = Pubid::Ieee.parse(
      "IEC 60076-21:2011 Edition 1.0 2011-12 IEEE Std C57.15",
    )
    expect(parsed.to_s)
      .to eq("IEC 60076-21 Edition 1.0 2011-12 and IEEE Std C57.15")
  end

  it "preserves the edition month and year" do
    parsed = Pubid::Ieee.parse(
      "IEC 60076-21:2011 Edition 1.0 2011-12 IEEE Std C57.15",
    )
    expect(parsed.to_s).to include("Edition 1.0 2011-12")
  end

  describe "regression checks" do
    it "still parses the bare IEC Edition form (no colon-year)" do
      parsed = Pubid::Ieee.parse("IEC 61671-2 Edition 1.0 2016-04")
      expect(parsed.to_s).to eq("IEC 61671-2 Edition 1.0 2016-04")
    end

    it "still parses the paren-wrapped IEEE co-published form" do
      parsed = Pubid::Ieee.parse(
        "IEC 61523-4 Edition 1.0 2015-03 (IEEE Std 1801-2013)",
      )
      expect(parsed.to_s)
        .to eq("IEC 61523-4 Edition 1.0 2015-03 (IEEE Std 1801-2013)")
    end
  end
end
