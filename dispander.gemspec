# frozen_string_literal: true

require_relative "lib/dispander/version"

Gem::Specification.new do |spec|
  spec.name = "dispander"
  spec.version = Dispander::VERSION
  spec.authors = ["sevenc-nanashi"]
  spec.email = ["sevenc-nanashi@sevenbot.jp"]

  spec.summary = "discorbのBotにメッセージ展開の機能を追加するExtension。"
  spec.homepage = "https://github.com/DiscordBotPortalJP/dispander.rb"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/DiscordBotPortalJP/dispander.rb"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "discorb", "~> 0.2.4"

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
