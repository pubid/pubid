# frozen_string_literal: true

require "spec_helper"

RSpec.describe Pubid::FormatRegistry do
  describe "parent chain" do
    it "falls back to the parent for renderers and parsers" do
      parent = described_class.new
      child = described_class.new(parent: parent)
      renderer = Class.new
      parent.register(:human, renderer: renderer)
      child.register(:short)

      expect(child.renderer_for(:human)).to eq(renderer)
      expect(child.renderer_for(:short)).to eq(nil)
      expect(parent.has?(:human)).to be true
      expect(child.has?(:short)).to be true
      expect(child.registered_formats).to contain_exactly(:short, :human)
    end
  end

  describe "lutaml-model mirror" do
    it "mirrors registrations into Lutaml::Model::FormatRegistry when loaded" do
      registry = described_class.new
      renderer = Class.new
      registry.register(:spec_mirror_fmt, renderer: renderer)

      expect(Lutaml::Model::FormatRegistry.registered?(:spec_mirror_fmt)).to be true
      expect(Lutaml::Model::FormatRegistry.adapter_class_for(:spec_mirror_fmt).pubid_renderer).to eq(renderer)
    end

    it "mirrors a shared format name once (first registration wins)" do
      # many flavors register :human with their own renderer; the global
      # lutaml registry carries one entry per format name — the first
      # flavor to load claims it. Per-flavor names are the L5-recommended
      # wire-up for the grammar-backed formats.
      expect(Lutaml::Model::FormatRegistry.registered?(:human)).to be true
      first = Lutaml::Model::FormatRegistry.adapter_class_for(:human)
      expect(first).to respond_to(:pubid_renderer)

      described_class.new.register(:human, renderer: Class.new)
      expect(Lutaml::Model::FormatRegistry.adapter_class_for(:human)).to equal(first)
    end

    it "does not overwrite an existing lutaml registration" do
      adapter = Class.new
      transformer = Class.new do
        define_singleton_method(:name) { "SpecTransform" }

        define_method(:data_to_model) { |data, _f, _o = {}| data }
      end
      Lutaml::Model::FormatRegistry.register(:already_there,
                                             mapping_class: Lutaml::Model::Mapping,
                                             adapter_class: adapter,
                                             transformer: transformer)
      described_class.new.register(:already_there, renderer: Class.new)

      expect(Lutaml::Model::FormatRegistry.adapter_class_for(:already_there)).to eq(adapter)
    end
  end
end
