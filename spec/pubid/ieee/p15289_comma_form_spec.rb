# frozen_string_literal: true

require "spec_helper"

RSpec.describe "IEEE P15289 comma-form draft — issue #206" do
  it "normalizes 'IEEE Unapproved Draft Std P15289, 06' to a parseable form" do
    parsed = Pubid::Ieee.parse("IEEE Unapproved Draft Std P15289, 06")
    expect(parsed).to be_a(Pubid::Ieee::Identifier)
    expect(parsed.to_s).to include("/D6")
  end
end
