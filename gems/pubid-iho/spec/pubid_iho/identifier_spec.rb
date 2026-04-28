module Pubid::Iho
  RSpec.describe Identifier do
    subject { described_class.parse(original || pubid) }
    let(:original) { nil }

    context "IHO S-44 5.0.0" do
      let(:pubid) { "IHO S-44 5.0.0" }

      it_behaves_like "converts pubid to pubid"
    end

    context "IHO S-100 5.2.0" do
      let(:pubid) { "IHO S-100 5.2.0" }

      it_behaves_like "converts pubid to pubid"
    end

    context "IHO M-3 2.0.0" do
      let(:pubid) { "IHO M-3 2.0.0" }

      it_behaves_like "converts pubid to pubid"
    end

    context "IHO B-4 2.19.0" do
      let(:pubid) { "IHO B-4 2.19.0" }

      it_behaves_like "converts pubid to pubid"
    end

    context "IHO C-13 1.0.0" do
      let(:pubid) { "IHO C-13 1.0.0" }

      it_behaves_like "converts pubid to pubid"
    end

    # letter-suffixed numbers (the letter is part of the document number)
    context "IHO S-5A 1.0.2" do
      let(:pubid) { "IHO S-5A 1.0.2" }

      it_behaves_like "converts pubid to pubid"
    end

    context "IHO S-8B 1.0.0" do
      let(:pubid) { "IHO S-8B 1.0.0" }

      it_behaves_like "converts pubid to pubid"
    end

    # colon-separated sub-publication
    context "IHO S-158:100 1.0.0" do
      let(:pubid) { "IHO S-158:100 1.0.0" }

      it_behaves_like "converts pubid to pubid"
    end

    # slash sub-part
    context "IHO P-1/21 1.0.0" do
      let(:pubid) { "IHO P-1/21 1.0.0" }

      it_behaves_like "converts pubid to pubid"
    end

    # hyphen sub-part
    context "IHO P-6-3 1.0.0" do
      let(:pubid) { "IHO P-6-3 1.0.0" }

      it_behaves_like "converts pubid to pubid"
    end

    # appendix with letter
    context "IHO S-65 Ap. A 1.0.0" do
      let(:pubid) { "IHO S-65 Ap. A 1.0.0" }

      it_behaves_like "converts pubid to pubid"
    end

    # appendix with number
    context "IHO S-53 Ap. 1 1.0.0" do
      let(:pubid) { "IHO S-53 Ap. 1 1.0.0" }

      it_behaves_like "converts pubid to pubid"
    end

    # part (relaton-iho issue 23)
    context "IHO S-100 Part 1 1.0.0" do
      let(:pubid) { "IHO S-100 Part 1 1.0.0" }

      it_behaves_like "converts pubid to pubid"
    end

    context "IHO S-100 Part A 1.0.0" do
      let(:pubid) { "IHO S-100 Part A 1.0.0" }

      it_behaves_like "converts pubid to pubid"
    end

    # part without version
    context "IHO S-100 Part A" do
      let(:pubid) { "IHO S-100 Part A" }

      it_behaves_like "converts pubid to pubid"
    end

    context "IHO S-4 Part 2 4.9.0" do
      let(:pubid) { "IHO S-4 Part 2 4.9.0" }

      it_behaves_like "converts pubid to pubid"
    end

    # part with letter suffix (S-100 Part 4a/4b/4c, Part 17a, etc.)
    context "IHO S-100 Part 4a 1.0.0" do
      let(:pubid) { "IHO S-100 Part 4a 1.0.0" }

      it_behaves_like "converts pubid to pubid"
    end

    context "IHO S-100 Part 4b 1.0.0" do
      let(:pubid) { "IHO S-100 Part 4b 1.0.0" }

      it_behaves_like "converts pubid to pubid"
    end

    context "IHO S-100 Part 4c 1.0.0" do
      let(:pubid) { "IHO S-100 Part 4c 1.0.0" }

      it_behaves_like "converts pubid to pubid"
    end

    context "IHO S-100 Part 17a 1.0.0" do
      let(:pubid) { "IHO S-100 Part 17a 1.0.0" }

      it_behaves_like "converts pubid to pubid"
    end

    # letter-suffixed part without version
    context "IHO S-100 Part 4a" do
      let(:pubid) { "IHO S-100 Part 4a" }

      it_behaves_like "converts pubid to pubid"
    end

    # letter-suffixed part without IHO prefix on input
    context "S-100 Part 4a 1.0.0 (without IHO prefix)" do
      let(:original) { "S-100 Part 4a 1.0.0" }
      let(:pubid) { "IHO S-100 Part 4a 1.0.0" }

      it_behaves_like "converts pubid to pubid"
    end

    # IHO prefix is optional on input, always emitted on output
    context "S-44 5.0.0 (without IHO prefix)" do
      let(:original) { "S-44 5.0.0" }
      let(:pubid) { "IHO S-44 5.0.0" }

      it_behaves_like "converts pubid to pubid"
    end

    describe "parse identifiers from examples files" do
      context "parses IHO identifiers from pubids.txt" do
        let(:examples_file) { "pubids.txt" }

        it_behaves_like "parse identifiers from file"
      end
    end
  end
end
