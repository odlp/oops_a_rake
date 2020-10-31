require_relative "lib/oops_a_rake/version"

Gem::Specification.new do |spec|
  spec.name = "oops_a_rake"
  spec.version = OopsARake::VERSION
  spec.authors = ["Oliver Peate"]

  spec.summary = "Write Rake tasks with plain Ruby objects"
  spec.homepage = "https://github.com/odlp/oops_a_rake"
  spec.license = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.5.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path("..", __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end

  spec.require_paths = ["lib"]

  spec.add_dependency "rake", ">= 12.0"

  spec.add_development_dependency "rspec"
end
