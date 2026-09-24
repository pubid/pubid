# frozen_string_literal: true

# Loads local, gitignored environment overrides (e.g. PUBID_TESTSUITE_PATH)
# from .env in `repo_root`, without overriding a variable already set in the
# shell. A relative value is resolved against repo_root, not the invoking
# shell's cwd, so a checkout-relative path (e.g. "../pubid-testsuite") stays
# portable across machines/containers instead of baking in an absolute one.
# Shared by Rakefile and spec/spec_helper.rb so `rake` and a direct `rspec`
# run parse `.env` identically.
module LocalEnv
  def self.load(repo_root)
    env_file = File.expand_path(".env", repo_root)
    return unless File.exist?(env_file)

    File.readlines(env_file).each do |line|
      key, value = parse_line(line)
      next unless key && value

      ENV[key] ||= resolve(value, repo_root)
    end
  end

  def self.parse_line(line)
    line = line.strip
    return if line.empty? || line.start_with?("#")

    key, value = line.split("=", 2)
    return unless key && value

    [key.strip, value.strip]
  end
  private_class_method :parse_line

  def self.resolve(value, repo_root)
    value = value[1..-2] if value.match?(/\A(['"]).*\1\z/)
    return value if value.start_with?("/")

    File.expand_path(value, repo_root)
  end
  private_class_method :resolve
end
