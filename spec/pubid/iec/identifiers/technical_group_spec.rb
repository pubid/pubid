# frozen_string_literal: true

require "spec_helper"

RSpec.describe Pubid::Iec::Identifiers::TechnicalGroup do
  describe "technical committee forms — issue #244" do
    {
      "IEC TC 1" => { publisher: "IEC", technical_committee: "TC 1", 
                      subcommittee: nil },
      "IEC PC 118" => { publisher: "IEC", technical_committee: "PC 118", 
                        subcommittee: nil },
      "IEC SC 100A" => { publisher: "IEC", technical_committee: "SC 100A", 
                         subcommittee: nil },
      "ISO/IEC JTC 1" => { publisher: "ISO/IEC", technical_committee: "JTC 1", 
                           subcommittee: nil },
      "ISO/IEC JPC 2" => { publisher: "ISO/IEC", technical_committee: "JPC 2", 
                           subcommittee: nil },
      "ISO/IEC JTC 1/SC 7" => { publisher: "ISO/IEC",
                                technical_committee: "JTC 1",
                                subcommittee: "/SC 7" },
      "IEC TC 100/SC 100A" => { publisher: "IEC",
                                technical_committee: "TC 100",
                                subcommittee: "/SC 100A" },
    }.each do |identifier, expected|
      context identifier do
        subject { Pubid::Iec.parse(identifier) }

        it "parses as TechnicalGroup" do
          expect(subject).to be_a(described_class)
        end

        it "captures technical_committee" do
          expect(subject.technical_committee)
            .to eq(expected[:technical_committee])
        end

        it "captures subcommittee" do
          expect(subject.subcommittee).to eq(expected[:subcommittee])
        end

        it "round-trips" do
          expect(subject.to_s).to eq(identifier)
        end
      end
    end
  end

  describe "bare committee forms" do
    # CISPR and CIS/X are IEC committees. The bare form parses and is
    # rendered with the default IEC publisher prefix.
    context "CISPR" do
      subject { Pubid::Iec.parse("CISPR") }

      it "parses as TechnicalGroup" do
        expect(subject).to be_a(described_class)
      end

      it "captures technical_committee" do
        expect(subject.technical_committee).to eq("CISPR")
      end

      it "renders with IEC publisher prefix" do
        expect(subject.to_s).to eq("IEC CISPR")
      end
    end

    context "CIS/A" do
      subject { Pubid::Iec.parse("CIS/A") }

      it "parses as TechnicalGroup" do
        expect(subject).to be_a(described_class)
      end

      it "captures the CIS/A committee identifier" do
        expect(subject.technical_committee).to eq("CIS/A")
      end

      it "renders with IEC publisher prefix" do
        expect(subject.to_s).to eq("IEC CIS/A")
      end
    end
  end

  describe "distinctness" do
    it "distinguishes TechnicalGroup from WorkingDocument" do
      tg = Pubid::Iec.parse("IEC TC 1")
      wd = Pubid::Iec.parse("100/3705/FDIS")
      expect(tg).to be_a(described_class)
      expect(wd).to be_a(Pubid::Iec::Identifiers::WorkingDocument)
      expect(tg).not_to eq(wd)
    end
  end
end
