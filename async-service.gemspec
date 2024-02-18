# frozen_string_literal: true

require_relative "lib/async/service/version"

Gem::Specification.new do |spec|
	spec.name = "async-service"
	spec.version = Async::Service::VERSION
	
	spec.summary = "A service layer for Async."
	spec.authors = ["Samuel Williams"]
	spec.license = "MIT"
	
	spec.cert_chain  = ['release.cert']
	spec.signing_key = File.expand_path('~/.gem/release.pem')
	
	spec.homepage = "https://github.com/socketry/async-service"
	
	spec.metadata = {
		"documentation_uri" => "https://socketry.github.io/async-service/",
	}
	
	spec.files = Dir.glob(['{lib}/**/*', '*.md'], File::FNM_DOTMATCH, base: __dir__)
	
	spec.required_ruby_version = ">= 3.0"
	
	spec.add_dependency "async"
	spec.add_dependency "async-container", "~> 0.16.0"
end
