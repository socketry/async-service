# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024-2025, by Samuel Williams.

def initialize(context)
	super
	
	require "async/service/configuration"
	
	@configuration = Async::Service::Configuration.new
end

attr :configuration

# Load the configuration from the given path.
# @parameter path [String] The path to the configuration file.
def load(path)
	@configuration.load_file(path)
end

# List the available services.
def list
	@configuration.services.map(&:to_h)
end
