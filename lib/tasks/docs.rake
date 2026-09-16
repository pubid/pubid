# frozen_string_literal: true

namespace :docs do
  desc "Generate identifier pattern reference docs"
  task :patterns do
    require "pubid"

    output_dir = File.join(__dir__, "..", "..", "docs", "identifier-patterns")
    FileUtils.mkdir_p(output_dir)

    lib_root = File.join(__dir__, "..", "..", "lib", "pubid")
    # The registry is the authoritative flavor list. This replaces a
    # filesystem glob over lib/pubid/* directories, whose reject list kept
    # going stale and swept internal modules (parsers, renderers, lutaml,
    # builder, utils, ...) in as "flavors". The module-derived directory
    # (CenCenelec -> cen_cenelec, W3c -> w3c) must exist on disk.
    Pubid.eager_load_flavors!
    flavors = Pubid::Registry.flavor_names.filter_map do |name|
      mod = Pubid::Registry.get(name)
      dir = mod.name.split("::").last
               .gsub(/([a-z\d])([A-Z])/, '\1_\2').downcase
      dir if File.directory?(File.join(lib_root, dir))
    end.uniq.sort

    flavors.each do |flavor|
      puts "Generating docs for #{flavor}..."
      generator = Pubid::Core::PatternDocGenerator.new(flavor)
      content = generator.generate
      File.write(File.join(output_dir, "#{flavor}.md"), content)
    end

    # Generate cross-flavor comparison table
    puts "Generating cross-flavor comparison..."
    table = Pubid::Core::PatternDocGenerator.generate_cross_flavor_table(flavors)
    File.write(File.join(output_dir, "README.md"), table)

    puts "Done. Generated docs for #{flavors.length} flavors in #{output_dir}/"
  end
end
