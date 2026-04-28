# frozen_string_literal: true

require "spec_helper"

RSpec.describe Pubid::Iho::Identifier do
  shared_examples "round-trips an IHO identifier" do
    it "parses #{} and renders the canonical form" do
      expect(Pubid::Iho.parse(input).to_s).to eq(canonical)
    end
  end

  describe ".parse" do
    {
      "IHO S-44 5.0.0"               => "IHO S-44 5.0.0",
      "IHO S-100 5.2.0"              => "IHO S-100 5.2.0",
      "IHO M-3 2.0.0"                => "IHO M-3 2.0.0",
      "IHO B-4 2.19.0"               => "IHO B-4 2.19.0",
      "IHO C-13 1.0.0"               => "IHO C-13 1.0.0",
      # letter-suffixed numbers (the letter is part of the document number)
      "IHO S-5A 1.0.2"               => "IHO S-5A 1.0.2",
      "IHO S-8B 1.0.0"               => "IHO S-8B 1.0.0",
      # colon-separated sub-publication
      "IHO S-158:100 1.0.0"          => "IHO S-158:100 1.0.0",
      # slash sub-part
      "IHO P-1/21 1.0.0"             => "IHO P-1/21 1.0.0",
      # hyphen sub-part
      "IHO P-6-3 1.0.0"              => "IHO P-6-3 1.0.0",
      # appendix with letter
      "IHO S-65 Ap. A 1.0.0"         => "IHO S-65 Ap. A 1.0.0",
      # appendix with number
      "IHO S-53 Ap. 1 1.0.0"         => "IHO S-53 Ap. 1 1.0.0",
      # part variants
      "IHO S-100 Part 1 1.0.0"       => "IHO S-100 Part 1 1.0.0",
      "IHO S-100 Part A 1.0.0"       => "IHO S-100 Part A 1.0.0",
      "IHO S-100 Part A"             => "IHO S-100 Part A",
      "IHO S-4 Part 2 4.9.0"         => "IHO S-4 Part 2 4.9.0",
      # part with letter suffix (relaton-iho issue 23)
      "IHO S-100 Part 4a 1.0.0"      => "IHO S-100 Part 4a 1.0.0",
      "IHO S-100 Part 4b 1.0.0"      => "IHO S-100 Part 4b 1.0.0",
      "IHO S-100 Part 4c 1.0.0"      => "IHO S-100 Part 4c 1.0.0",
      "IHO S-100 Part 17a 1.0.0"     => "IHO S-100 Part 17a 1.0.0",
      "IHO S-100 Part 4a"            => "IHO S-100 Part 4a",
      # IHO prefix is optional on input, always emitted on output
      "S-100 Part 4a 1.0.0"          => "IHO S-100 Part 4a 1.0.0",
      "S-44 5.0.0"                   => "IHO S-44 5.0.0",
    }.each do |input, canonical|
      context "with #{input.inspect}" do
        let(:input)     { input }
        let(:canonical) { canonical }

        it_behaves_like "round-trips an IHO identifier"
      end
    end

    it "raises on garbage input" do
      expect { Pubid::Iho.parse("not an IHO identifier") }.to raise_error(/Failed to parse IHO identifier/)
    end
  end

  describe "type-specific dispatch" do
    {
      "S" => Pubid::Iho::Identifiers::Standard,
      "P" => Pubid::Iho::Identifiers::Publication,
      "M" => Pubid::Iho::Identifiers::Miscellaneous,
      "B" => Pubid::Iho::Identifiers::Bibliographic,
      "C" => Pubid::Iho::Identifiers::CircularLetter,
    }.each do |letter, klass|
      it "maps the #{letter}- prefix to #{klass.name.split('::').last}" do
        expect(Pubid::Iho.parse("IHO #{letter}-1 1.0.0")).to be_a(klass)
      end
    end
  end
end
