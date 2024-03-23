# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024, by Samuel Williams.

require_relative 'loader'
require_relative 'generic'
require_relative 'controller'

module Async
	module Service
		# Manages environments which describes how to host a specific set of services.
		#
		# Environments are key-value maps with lazy value resolution. An environment can inherit from a parent environment, which can provide defaults
		class Configuration
			def self.load(paths = ARGV)
				configuration = self.new
				
				paths.each do |path|
					configuration.load_file(path)
				end
				
				return configuration
			end
			
			def self.for(*environments)
				self.new(environments)
			end
			
			# Initialize an empty configuration.
			def initialize(environments = [])
				@environments = environments
			end
			
			attr :environments
			
			def empty?
				@environments.empty?
			end
			
			def services(implementing: nil)
				return to_enum(:services, implementing: implementing) unless block_given?
				
				@environments.each do |environment|
					next if implementing and environment.implements?(implementing)
					
					yield Generic.wrap(environment)
				end
			end
			
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
