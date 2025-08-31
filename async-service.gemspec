# frozen_string_literal: true

require_relative "lib/async/service/version"

Gem::Specification.new do |spec|
	spec.name = "async-service"
	spec.version = Async::Service::VERSION
	
	spec.summary = "A service layer for Async."
	spec.authors = ["Samuel Williams"]
	spec.license = "MIT"
	
	spec.cert_chain  = ["release.cert"]
	spec.signing_key = File.expand_path("~/.gem/release.pem")
	
	spec.homepage = "https://github.com/socketry/async-service"
	
	spec.metadata = {
		"documentation_uri" => "https://socketry.github.io/async-service/",
		"source_code_uri" => "https://github.com/socketry/async-service.git",
	}
	
	spec.files = Dir.glob(["{bin,context,lib}/**/*", "*.md"], File::FNM_DOTMATCH, base: __dir__)
	
	spec.executables = ["async-service"]
	
	spec.required_ruby_version = ">= 3.2"
	
	spec.add_dependency "async"
	spec.add_dependency "async-container", "~> 0.16"
	spec.add_dependency "string-format", "~> 0.2"
end
