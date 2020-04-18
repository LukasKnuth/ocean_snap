require_relative 'lib/backup_retention/version'

Gem::Specification.new do |spec|
  spec.name          = "backup_retention"
  spec.version       = BackupRetention::VERSION
  spec.authors       = ["Lukas Knuth"]
  spec.email         = ["mr.luke.187@googlemail.com"]

  spec.summary       = "Chooses DigitalOcean Volume Snapshot backups to retain"
  spec.description   = "Given a set of rules, chooses any volume snapshots to be retained for later restoring."
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Dependencies
  spec.add_dependency 'thor', '~> 1.0.1'
  spec.add_dependency 'droplet_kit', '~> 3.7.0'
end
