require "spec_helper"

# Regression: the NIST v2 data corpus carries a spurious "U" that a bad
# migration prefixed onto real letter/revision suffixes (e.g. "800-38a" ->
# "800-38Ua"). The parser used to leak Parslet internals for these, e.g.
# "NIST SP 800-38{LETTER_SUFFIX_EXTRA: \"A\"@15}". The preprocessor now strips
# the spurious "U" so the identifier normalizes to its authoritative form.
RSpec.describe "NIST spurious 'U' suffix normalization" do
  {
    "NIST NCSTAR 1-1Ub" => "NIST NCSTAR 1-1B",
    "NIST SP 800-38Ua" => "NIST SP 800-38A",
    "NBS IR 78-1143Ua" => "NBS IR 78-1143A",
    "NIST HB 150-2Ud" => "NIST HB 150-2D",
    # "r" is a revision marker, not a letter suffix: "73-197Ur" -> "73-197r"
    # which the parser renders as its canonical "r1" revision form.
    "NBS IR 73-197Ur" => "NBS IR 73-197r1",
  }.each do |input, expected|
    describe input do
      let(:rendered) { Pubid::Nist.parse(input).to_s }

      it "normalizes to #{expected}" do
        expect(rendered).to eq(expected)
      end

      it "does not leak Parslet parse-tree internals" do
        expect(rendered).not_to match(/[@{]/)
      end
    end
  end
end
