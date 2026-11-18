# frozen_string_literal: true

require "spec_helper"

ARXIV_FIXTURE_ROOT = File.expand_path("../../fixtures/arxiv/identifiers",
                                      __dir__)

# Every pass fixture renders to its recorded form, every fail fixture raises,
# and the two buckets hold exactly the inputs of full/ (the CSA shape).
RSpec.describe "arXiv fixtures" do
  include FixtureFileHelper

  def self.files(bucket)
    Dir.glob(File.join(ARXIV_FIXTURE_ROOT, bucket, "*.txt"))
  end

  def files(bucket)
    self.class.files(bucket)
  end

  it "finds the fixture files" do
    expect(%w[pass fail full].map { |b| files(b) }).to all(be_any)
  end

  files("pass").each do |file|
    it "round-trips every entry of pass/#{File.basename(file)}" do
      read_pass_fixture_entries(file).each do |input, rendered|
        expect(Pubid::Arxiv.parse(input).to_s).to eq(rendered)
      end
    end
  end

  files("fail").each do |file|
    it "rejects every entry of fail/#{File.basename(file)}" do
      read_fail_fixture_inputs(file).each do |input|
        expect { Pubid::Arxiv.parse(input) }
          .to raise_error(Pubid::Errors::ParseError)
      end
    end
  end

  it "keeps pass/ + fail/ equal to full/" do
    passed = files("pass").flat_map do |f|
      read_pass_fixture_entries(f).map(&:first)
    end
    failed = files("fail").flat_map { |f| read_fail_fixture_inputs(f) }
    full = files("full").flat_map { |f| read_fixture_file(f) }
    expect((passed + failed).sort).to eq(full.sort)
  end
end
