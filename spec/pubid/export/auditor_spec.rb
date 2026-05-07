# frozen_string_literal: true

require "spec_helper"
require "pubid/export"

RSpec.describe Pubid::Export::Auditor do
  subject { described_class.new(generated_data) }

  let(:generated_data) do
    {
      "iso" => {
        "identifier_types" => [
          { "key" => "is", "title" => "International Standard" },
          { "key" => "tr", "title" => "Technical Report" },
        ],
      },
      "iec" => {
        "identifier_types" => [
          { "key" => "is", "title" => "International Standard" },
        ],
      },
    }
  end

  let(:website_data) do
    {
      "iso" => {
        "doc_types" => [
          { "key" => "is" },
        ],
      },
      "iec" => {
        "doc_types" => [
          { "key" => "is" },
          { "key" => "tr" },
        ],
      },
    }
  end

  describe "#initialize" do
    it "stores generated data" do
      expect(subject.generated).to eq(generated_data)
    end
  end

  describe ".from_file" do
    it "loads data from a JSON file" do
      require "tempfile"
      file = Tempfile.new(["export", ".json"])
      file.write(JSON.generate(generated_data))
      file.close

      auditor = described_class.from_file(file.path)
      expect(auditor.generated).to eq(generated_data)
    ensure
      file.unlink
    end
  end

  describe "#audit" do
    it "returns results for each generated flavor" do
      results = subject.audit(website_data)
      expect(results).to have_key("iso")
      expect(results).to have_key("iec")
    end

    it "detects missing types from website" do
      results = subject.audit(website_data)
      missing = results["iso"][:missing_types]
      expect(missing.size).to eq(1)
      expect(missing.first["key"]).to eq("tr")
    end

    it "detects extra types in website" do
      results = subject.audit(website_data)
      extra = results["iec"][:extra_types]
      expect(extra).to include("tr")
    end

    it "flags flavors only in website" do
      website = website_data.merge("bsi" => { "doc_types" => [{ "key" => "bs" }] })
      results = subject.audit(website)
      expect(results["bsi"]).to eq({ missing_from_library: true })
    end

    it "returns empty result when perfectly aligned" do
      perfect_website = {
        "iso" => {
          "doc_types" => [
            { "key" => "is" },
            { "key" => "tr" },
          ],
        },
        "iec" => {
          "doc_types" => [
            { "key" => "is" },
          ],
        },
      }
      results = subject.audit(perfect_website)
      expect(results["iso"][:missing_types]).to be_empty
      expect(results["iso"][:extra_types]).to be_empty
    end
  end

  describe "#summary" do
    it "produces a readable summary string" do
      results = subject.audit(website_data)
      summary = subject.summary(results)
      expect(summary).to start_with("Audit Summary:")
      expect(summary).to include("MISSING from website")
      expect(summary).to include("EXTRA in website")
    end
  end
end
