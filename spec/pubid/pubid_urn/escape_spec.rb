# frozen_string_literal: true

require "spec_helper"

# The pubid-scheme URN is also an HTTP path slug (relaton/relaton#441), so
# its escape cannot use "%": servers and proxies decode "%2F" before routing,
# or refuse it. "~XX" (uppercase hex of each UTF-8 byte) has no meaning in a
# path, and "~" is an RFC 3986 unreserved character.
RSpec.describe Pubid::PubidUrn::Escape do
  describe ".encode" do
    it "keeps the path-safe characters as they are" do
      expect(described_class.encode("ABC-def_1.2")).to eq("ABC-def_1.2")
    end

    it "escapes every structural or path-unsafe character" do
      expect(described_class.encode("a:b/c d,e(f)g~h%i?j#k+l"))
        .to eq("a~3Ab~2Fc~20d~2Ce~28f~29g~7Eh~25i~3Fj~23k~2Bl")
    end

    it "escapes each UTF-8 byte of a non-ASCII character" do
      expect(described_class.encode("ГОСТ")).to eq("~D0~93~D0~9E~D0~A1~D0~A2")
    end
  end

  describe ".decode" do
    it "reverses .encode" do
      ["9001", "a:b/c d", "ГОСТ Р 1.0", "~", "x~y", "Ed 13", ""].each do |s|
        expect(described_class.decode(described_class.encode(s))).to eq(s)
      end
    end

    it "refuses a lower-case escape, which is not canonical" do
      expect { described_class.decode("a~3ab") }
        .to raise_error(Pubid::Errors::UrnParseError, /escape/)
    end

    # An escape of a path-safe character is legal here: the codec escapes the
    # first character of a core value that would otherwise read as structure
    # ("amd" -> "~61md"). The codec, not this layer, refuses an escape that
    # the canonical form does not need.
    it "accepts the escape of a path-safe character" do
      expect(described_class.decode("~61md")).to eq("amd")
    end

    it "refuses a raw character outside the path-safe set" do
      expect { described_class.decode("a b") }
        .to raise_error(Pubid::Errors::UrnParseError)
    end

    it "refuses a truncated escape" do
      expect { described_class.decode("a~4") }
        .to raise_error(Pubid::Errors::UrnParseError)
    end
  end
end
