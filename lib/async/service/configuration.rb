# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024, by Samuel Williams.

require_relative 'loader'
require_relative 'generic'

module Async
	module Service
		# Manages environments which describes how to host a specific set of services.
		#
		# Environments are key-value maps with lazy value resolution. An environment can inherit from a parent environment, which can provide defaults
		class Configuration
			# Initialize an empty configuration.
			def initialize
				@environments = []
			end
			
			def empty?
				@environments.empty?
			end
			
			def services
				return to_enum(:services) unless block_given?
				
				@environments.each do |environment|
					yield Generic.wrap(environment)
				end
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
