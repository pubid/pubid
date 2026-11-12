# frozen_string_literal: true

# The doi spike's parity gate (pubid/pubid#706 §9): over ALL doi inputs —
# the coded flavor's fixtures, the corpus rows with their aliases, and the
# constructed edge cases — the PFS-compiled `doi_pfs` flavor and the coded
# `doi` flavor must agree byte-for-byte on to_s / to_hash / to_urn /
# to_mr_string / to_pubid_urn, and fail on the same inputs with the same
# error class. Drift is a defect in the DEFINITION or the compiler, never
# a reason to relax an expectation here.

require "pubid"

# Every doi input in the fleet inventory: the coded flavor's pass
# fixtures (canonical, upper_scheme, url_form), the corpus rows
# (resource.yaml + their non_normalized_aliases), and the constructed
# edge cases (face combinations, suffix charset corners, registrar
# widths).
PARITY_INPUTS = [
  "doi:10.1000/182",
  "DOI:10.1000/182",
  "Doi:10.1000/182",
  "10.1000/182",
  "/10.1000/182",
  "doi:/10.1000/182",
  "https://doi.org/10.1000/182",
  "http://doi.org/10.1000/182",
  "https://10.1000/182",
  "http://10.1000/182",
  "doi.org/10.1000/182",
  "10.1006/jmbi.1998.2354",
  "DOI:10.6028/NIST.2022-04-15.001",
  "10.6028/NIST.2022-04-15.001",
  "https://doi.org/10.6028/NIST.2022-04-15.001",
  "10.5291/TRENDSCAN-DATA-2018(a)",
  "10.1000/abc_def-xyz.2023",
  "10.10000/long-registrar",
].freeze

# The coded fixtures' negatives plus the charset corners: a DOI-reserved
# exclusion (":"), whitespace, a missing suffix, a too-short registrar,
# junk.
PARITY_NEGATIVES = [
  "doi:",
  "doi:10",
  "doi:10.X/abc",
  "doi:10.1000/",
  "nonsense",
  "10.X/abc",
  "10.1/abc", # 2*digit means two or more registrar digits
  "10./abc",
  "doi:abc/def",
  "doi:10.1000/a b", # whitespace is excluded
  "doi:10.1000/a:b", # ":" is a DOI-reserved exclusion
  "https://doi.org/",
  "10.1000",
  # The combined faces (url prefix + scheme face): the CODED flavor
  # rejects them, so parity means rejecting them too.
  "https://doi.org/doi:10.1000/182",
  "https://doi.org/DOI:10.1000/182",
  "http://doi.org/doi:10.1000/182",
].freeze

RSpec.describe "Pubid::DoiPfs parity with the coded Pubid::Doi" do
  PARITY_INPUTS.each do |input|
    it "agrees byte-for-byte with the coded flavor on #{input.inspect}" do
      coded = Pubid::Doi.parse(input)
      pfs = Pubid::DoiPfs.parse(input)

      # Class-equivalent semantics: distinct classes, same shape.
      expect(pfs.class).to be < Pubid::Identifier
      expect(pfs.class).not_to eq(coded.class)
      expect(pfs.prefix).to eq(coded.prefix)
      expect(pfs.suffix).to eq(coded.suffix)

      expect(pfs.to_s).to eq(coded.to_s)
      expect(pfs.to_hash).to eq(coded.to_hash)
      expect(pfs.to_urn).to eq(coded.to_urn)
      expect(pfs.to_mr_string).to eq(coded.to_mr_string)
      expect(pfs.to_pubid_urn).to eq(coded.to_pubid_urn)
    end

    it "round-trips #{input.inspect} through its own from_hash" do
      pfs = Pubid::DoiPfs.parse(input)
      expect(Pubid::DoiPfs::Identifier.from_hash(pfs.to_hash)).to eq(pfs)
    end
  end

  PARITY_NEGATIVES.each do |input|
    it "rejects #{input.inspect} like the coded flavor" do
      expect { Pubid::Doi.parse(input) }
        .to raise_error(Pubid::Errors::ParseError)
      expect { Pubid::DoiPfs.parse(input) }
        .to raise_error(Pubid::Errors::ParseError)
    end
  end

  it "shares the input guards with the coded flavor" do
    [Pubid::Doi, Pubid::DoiPfs].each do |flavor|
      expect { flavor.parse(42) }
        .to raise_error(Pubid::Errors::InvalidInputError, Pubid::INPUT_NOT_A_STRING_MESSAGE)
      expect { flavor.parse("x" * (Pubid::MAX_INPUT_LENGTH + 1)) }
        .to raise_error(Pubid::Errors::InvalidInputError,
                        Pubid::INPUT_TOO_LONG_MESSAGE)
    end
  end

  it "never hijacks Pubid.parse — the coded flavor keeps routing doi" do
    expect(Pubid.parse("doi:10.1000/182")).to be_a(Pubid::Doi::Identifier)
  end

  it "registers beside the coded flavor (coexistence, not cutover)" do
    expect(Pubid::Registry.registered?(:doi)).to be(true)
    expect(Pubid::Registry.registered?(:doi_pfs)).to be(true)
    # The dev alias declares the scheme-canonical namespace, so its URN
    # generator pins the doi namespace while its schema registers under
    # its own key.
    expect(Pubid::DoiPfs::UrnGenerator.new(nil).urn_namespace).to eq("doi")
    expect(Pubid::PubidUrn.flavor_schema("doi_pfs")).not_to be_nil
    expect(Pubid::PubidUrn.flavor_schema("doi")).not_to be_nil
  end
end
