require_relative "lib/based_uuid/version"

Gem::Specification.new do |spec|
  spec.name = "based_uuid"
  spec.version = BasedUUID::VERSION
  spec.authors = ["Piotr Chmolowski"]
  spec.email = ["piotr@chmolowski.pl"]

  spec.summary = "URL-friendly, Base32-encoded UUIDs for Rails models"
  spec.homepage = "https://github.com/pchm/based_uuid"
  spec.required_ruby_version = ">= 3.2.0"
  spec.license = "MIT"

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor Gemfile])
    end
  end
  spec.require_paths = ["lib"]

  spec.add_dependency "activerecord", ">= 7.0"
  spec.add_dependency "activesupport", ">= 7.0"
end
