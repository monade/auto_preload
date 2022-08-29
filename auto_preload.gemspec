# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require_relative "lib/auto_preload/version"

Gem::Specification.new do |spec|
  spec.name          = "auto_preload"
  spec.version       = AutoPreload::VERSION
  spec.authors       = ["Mònade"]
  spec.email         = ["team@monade.io"]

  spec.summary       = "A gem to run nested preloads/includes from string."
  spec.description   = "A gem to run nested preloads/includes from string."
  spec.homepage      = "https://github.com/monade/auto_preload"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 2.7"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "https://github.com/monade/auto_preload/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "activerecord", [">= 5", "< 8"]
  spec.add_dependency "activesupport", [">= 5", "< 8"]

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
