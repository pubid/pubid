# frozen_string_literal: true

require "spec_helper"

RSpec.describe Pubid::Itu::Identifiers::Handbook do
  describe "ITU-R Handbooks" do
    %w[ITU-R\ 23.HDB ITU-R\ 42.HDB ITU-R\ 01.HDB].each do |id|
      context id do
        subject { id }

        let(:parsed) { Pubid::Itu.parse(subject) }

        it "parses as Handbook" do
          expect(parsed).to be_a(described_class)
        end

        it "parses sector" do
          expect(parsed.sector.sector).to eq("R")
        end

        it "has no series" do
          expect(parsed.series).to be_nil
        end

        it "parses number" do
          expect(parsed.code.number).to eq(id[/(\d+)\.HDB/, 1])
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end

        it "carries the handbook _type" do
          expect(parsed.to_hash["_type"]).to eq("pubid:itu:handbook")
        end

        it "round-trips through hash" do
          hash = parsed.to_hash
          expect(Pubid::Itu::Identifier.from_hash(hash).to_hash).to eq(hash)
        end
      end
    end
  end
end
