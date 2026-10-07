# frozen_string_literal: true

require "spec_helper"
require "parsanol/parg"

# G4 pilot: the ISO grammar artifact as a grammar-backed lutaml-model
# string format — the L1/L5 chain (artifact + bindings + model class,
# no hand-rolled from_h/to_h anywhere) proven on a real flavor.
RSpec.describe "ISO grammar pilot" do
  let(:artifact) do
    File.expand_path("../../data/parg/iso.json", __dir__)
  end

  let(:tables_dir) do
    File.expand_path("../../data/parg/tables", __dir__)
  end

  let(:iso_identifier_class) do
    Class.new(Lutaml::Model::Serializable) do
      attribute :publisher, :string
      attribute :number_with_part, :string
      attribute :date, :integer
    end
  end

  it "parses identifiers through the artifact into the model" do
    Parsanol::PARG::Lutaml.register(
      iso_identifier_class,
      format_name: :pubid_iso_pilot,
      artifact: artifact,
      entry: "identifier",
      # parsanol 1.3.79's fast lane (rs#162) compiles the entry lazily
      # and resolves table atoms at compile time; the load-path default
      # is dirname(artifact) = data/parg, but the tables live in
      # data/parg/tables (the runtime backend passes TABLES_DIR for
      # the same reason).
      tables_dir: tables_dir,
    )

    parsed = iso_identifier_class.from_pubid_iso_pilot("ISO 12345:2020")
    expect(parsed.publisher).to eq("ISO")
    expect(parsed.number_with_part).to eq("12345")
    expect(parsed.date).to eq(2020)
  end

  it "registers the format in the single FormatRegistry" do
    Parsanol::PARG::Lutaml.register(
      iso_identifier_class,
      format_name: :pubid_iso_pilot_registry,
      artifact: artifact,
      entry: "identifier",
      # parsanol 1.3.79's fast lane (rs#162) compiles the entry lazily
      # and resolves table atoms at compile time; the load-path default
      # is dirname(artifact) = data/parg, but the tables live in
      # data/parg/tables (the runtime backend passes TABLES_DIR for
      # the same reason).
      tables_dir: tables_dir,
    )

    expect(Lutaml::Model::FormatRegistry.registered?(:pubid_iso_pilot_registry)).to be(true)
  end
end
