# frozen_string_literal: true

require "spec_helper"

# lutaml's ComparableModel#== is an alias of its #eql?(other,
# compared_objects = {}). When an attribute holds a model of the SAME
# class, lutaml recurses with two arguments, so an override of #eql? that
# takes only one raises ArgumentError from inside #==. IEEE stores the
# revised standard in an attribute of the same class, so every IEEE
# "Revision of" id raised on #== (and so on #matches?).
RSpec.describe "Pubid::Identifier#eql? arity" do
  [
    "IEEE Std 1207-2011 (Revision to IEEE Std 1207-2004)",
    "IEEE Std C57.12.60-2009 ( Revision of IEEE Std C57.12.60-1998)",
  ].each do |input|
    it "compares #{input} with #== without raising" do
      a = Pubid::Ieee.parse(input)
      b = Pubid::Ieee.parse(input)
      expect(a == b).to be(true)
      expect(a).to eql(b)
    end

    it "matches #{input} against its from_hash copy" do
      id = Pubid::Ieee.parse(input)
      copy = Pubid::Ieee::Identifier.from_hash(id.to_hash)
      expect(id.matches?(copy)).to be(true)
    end
  end

  it "tells two different revisions apart" do
    a = Pubid::Ieee.parse("IEEE Std 1207-2011 (Revision to IEEE Std 1207-2004)")
    b = Pubid::Ieee.parse("IEEE Std 1207-2011 (Revision to IEEE Std 1207-2003)")
    expect(a == b).to be(false)
    expect(a).not_to eql(b)
  end

  it "accepts lutaml's second argument on every identifier" do
    expect(Pubid::Identifier.instance_method(:eql?).arity).to eq(-2)
  end
end
