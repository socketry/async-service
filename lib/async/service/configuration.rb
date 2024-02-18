# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2023, by Samuel Williams.
# Copyright, 2019, by Sho Ito.

require 'build/environment'

module Async
	module Service
		# Manages environments which describes how to host a specific set of services.
		#
		# Environments are key-value maps with lazy value resolution. An environment can inherit from a parent environment, which can provide defaults
		class Configuration
			# Initialize an empty configuration.
			def initialize
				@environments = {}
			end
			
			# The map of named environments.
			# @attribute [Hash(String, Build::Environment)]
			attr :environments
			
			# Enumerate all environments that have the specified key.
			# @parameter key [Symbol] Filter environments that don't have this key.
			def each(key = :authority)
				return to_enum(key) unless block_given?
				
				@environments.each do |name, environment|
					environment = environment.flatten
					
					if environment.include?(key)
						yield environment
					end
				end
			end
			
			# Add the named environment to the configuration.
			def add(environment)
				name = environment.name
				
				unless name
					raise ArgumentError, "Environment name is nil #{environment.inspect}"
				end
				
				environment = environment.flatten
				
				raise KeyError.new("#{name.inspect} is already set", key: name) if @environments.key?(name)
				
				@environments[name] = environment
			end
			
			# Load the specified configuration file. See {Loader#load_file} for more details.
			def load_file(path)
				Loader.load_file(self, path)
			end
			

		end
	end
end
