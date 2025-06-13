# frozen_string_literal: true

require_relative "lib/cloudflare_rails_router/version"

Gem::Specification.new do |spec|
  spec.name = "cloudflare_rails_router"
  spec.version = CloudflareRailsRouter::VERSION
  spec.authors = ["Kieran Klaassen"]
  spec.email = ["kieranklaassen@gmail.com"]

  spec.summary = "Same-domain edge routing between Rails and marketing sites"
  spec.description = "Route anonymous visitors to marketing pages and authenticated users to your Rails app, all on the same domain using Cloudflare Workers"
  spec.homepage = "https://github.com/kieranklaassen/cloudflare_rails_router"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/kieranklaassen/cloudflare_rails_router"
  spec.metadata["changelog_uri"] = "https://github.com/kieranklaassen/cloudflare_rails_router/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Runtime dependencies
  spec.add_dependency "rails", ">= 6.0"

  # Development dependencies
  spec.add_development_dependency "rspec-rails"
  spec.add_development_dependency "generator_spec"
end
