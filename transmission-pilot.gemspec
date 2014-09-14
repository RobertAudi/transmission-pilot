Gem::Specification.new do |spec|
  spec.name          = "transmission-pilot"
  spec.version       = File.read("VERSION")
  spec.author        = "Robert Audi"
  spec.email         = "robert.audii@gmail.com"
  spec.homepage      = "https://github.com/RobertAudi/transmission-pilot"
  spec.summary       = "Interact with the Transmission daemon"
  spec.description   = "Command-line app to interact with the Transmission daemon"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").delete_if { |f| f =~ /\.gitkeep/ }
  spec.require_paths << "lib"
  spec.bindir = "bin"
  spec.executables = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }

  spec.add_runtime_dependency "oj", "~> 2.10.2"
  spec.add_runtime_dependency "faraday", "~> 0.9.0"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
