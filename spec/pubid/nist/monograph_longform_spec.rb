# frozen_string_literal: true

require "spec_helper"

RSpec.describe "NIST Monograph long-form series name — issue #189" do
  it "normalizes 'Monograph' to 'MONO' for NIST publisher" do
    parsed = Pubid::Nist.parse("NIST Monograph 125")
    expect(parsed.series.value).to eq("MONO")
    expect(parsed.to_s).to eq("NIST MONO 125")
  end

  it "normalizes 'Monograph' to 'MONO' for NBS publisher" do
    parsed = Pubid::Nist.parse("NBS Monograph 125")
    expect(parsed.series.value).to eq("MONO")
    expect(parsed.to_s).to eq("NBS MONO 125")
  end

  it "parses the abbreviated form unchanged" do
    parsed = Pubid::Nist.parse("NIST MONO 125")
    expect(parsed.to_s).to eq("NIST MONO 125")
  end
end
