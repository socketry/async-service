# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024-2025, by Samuel Williams.

require_relative "loader"
require_relative "generic_service"
require_relative "controller"

module Async
	module Service
		# Manages environments which describes how to host a specific set of services.
		#
		# Environments are key-value maps with lazy value resolution. An environment can inherit from a parent environment, which can provide defaults
		class Configuration
			# Build a configuration using a block.
			# @parameter root [String] The root directory for loading files.
			# @yields {|loader| ...} A loader instance for configuration.
			# @returns [Configuration] A new configuration instance.
			def self.build(root: Dir.pwd, &block)
				configuration = self.new
				
				loader = Loader.new(configuration, root)
				loader.instance_eval(&block)
				
				return configuration
			end
			
			# Load configuration from file paths.
			# @parameter paths [Array(String)] File paths to load, defaults to `ARGV`.
			# @returns [Configuration] A new configuration instance.
			def self.load(paths = ARGV)
				configuration = self.new
				
				paths.each do |path|
					configuration.load_file(path)
				end
				
				return configuration
			end
			
			# Create configuration from environments.
			# @parameter environments [Array] Environment instances.
			# @returns [Configuration] A new configuration instance.
			def self.for(*environments)
				self.new(environments)
			end
			
			# Initialize an empty configuration.
			def initialize(environments = [])
				@environments = environments
			end
			
			attr :environments
			
			# Check if the configuration is empty.
			# @returns [Boolean] True if no environments are configured.
			def empty?
				@environments.empty?
			end
			
			# Enumerate all services in the configuration.
			#
			# A service is an environment that has a `service_class` key.
			#
			# @parameter implementing [Module] If specified, only services implementing this module will be returned/yielded.
			# @yields {|service| ...} Each service in the configuration.
			def services(implementing: nil)
				return to_enum(:services, implementing: implementing) unless block_given?
				
				@environments.each do |environment|
					if implementing.nil? or environment.implements?(implementing)
						if service = GenericService.wrap(environment)
							yield service
						end
					end
				end
			end
			
			# Create a controller for the configured services.
			#
			# @returns [Controller] A controller that can be used to start/stop services.
			def controller(**options)
				Controller.new(self.services(**options).to_a)
			end
			
			# Add the environment to the configuration.
			def add(environment)
				@environments << environment
			end
			
			# Load the specified configuration file. See {Loader#load_file} for more details.
			def load_file(path)
				Loader.load_file(self, path)
			end
		end
	end
end
