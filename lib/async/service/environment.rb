# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024-2025, by Samuel Williams.

module Async
	module Service
		# Represents a service configuration with lazy evaluation and module composition.
		#
		# Environments store configuration as methods that can be overridden and composed using Ruby modules. They support lazy evaluation through evaluators.
		class Environment
			# A builder for constructing environments using a DSL.
			class Builder < BasicObject
				# Create a new environment with facets and values.
				# @parameter facets [Array(Module)] Modules to include in the environment.
				# @parameter values [Hash] Key-value pairs to define as methods.
				# @parameter block [Proc] A block for additional configuration.
				# @returns [Module] The constructed environment module.
				def self.for(*facets, **values, &block)
					top = ::Module.new
					
					builder = self.new(top)
					
					facets.each do |facet|
						builder.include(facet)
					end
					
					values.each do |key, value|
						if value.is_a?(::Proc)
							builder.method_missing(key, &value)
						else
							builder.method_missing(key, value)
						end
					end
					
					# This allows for a convenient syntax, e.g.:
					#
					# 	Builder.for do
					# 		foo 42
					# 	end
					#
					# or:
					#
					# 	Builder.for do |builder|
					# 		builder.foo 42
					# 	end 
					if block_given?
						if block.arity == 0
							builder.instance_exec(&block)
						else
							yield builder
						end
					end
					
					return top
				end
				
				# Initialize a new builder.
				# @parameter facet [Module] The module to build into, defaults to a new `Module`.
				def initialize(facet = ::Module.new)
					@facet = facet
				end
				
				# Include a module or other includable object into the environment.
				# @parameter target [Module] The module to include.
				def include(target)
					if target.class == ::Module
						@facet.include(target)
					elsif target.respond_to?(:included)
						target.included(@facet)
					else
						::Kernel.raise ::ArgumentError, "Cannot include #{target.inspect} into #{@facet.inspect}!"
					end
				end
				
				# Define methods dynamically on the environment.
				# @parameter name [Symbol] The method name to define.
				# @parameter argument [Object] The value to return from the method.
				# @parameter block [Proc] A block to use as the method implementation.
				def method_missing(name, argument = nil, &block)
					if block
						@facet.define_method(name, &block)
					else
						@facet.define_method(name){argument}
					end
				end
			end
			
			# Build a new environment using the builder DSL.
			# @parameter arguments [Array] Arguments passed to Builder.for
			# @returns [Environment] A new environment instance.
			def self.build(...)
				Environment.new(Builder.for(...))
			end
			
			# Initialize a new environment.
			# @parameter facet [Module] The facet module containing the configuration methods.
			# @parameter parent [Environment | Nil] The parent environment for inheritance.
			def initialize(facet = ::Module.new, parent = nil)
				unless facet.class == ::Module
					raise ArgumentError, "Facet must be a module!"
				end
				
				@facet = facet
				@parent = parent
			end
			
			# @attribute [Module] The facet module.
			attr :facet
			
			# @attribute [Environment | Nil] The parent environment, if any.
			attr :parent
			
			# Include this environment's facet into a target module.
			# @parameter target [Module] The target module to include into.
			def included(target)
				@parent&.included(target)
				target.include(@facet)
			end
			
			# Create a new environment with additional configuration.
			# @parameter arguments [Array] Arguments passed to Environment.build.
			# @returns [Environment] A new environment with this as parent.
			def with(...)
				return self.class.new(Builder.for(...), self)
			end
			
			# Check if this environment implements a given interface.
			# @parameter interface [Module] The interface to check.
			# @returns [Boolean] True if this environment implements the interface.
			def implements?(interface)
				@facet <= interface
			end
			
			# An evaluator is lazy read-only view of an environment. It memoizes all method calls.
			class Evaluator
				# Create an evaluator wrapper for an environment.
				# @parameter environment [Environment] The environment to wrap.
				# @returns [Evaluator] A new evaluator instance.
				def self.wrap(environment)
					evaluator = ::Class.new(self)
					
					facet = ::Module.new
					environment.included(facet)
					
					evaluator.include(facet)
					
					keys = []
					
					# Memoize all instance methods:
					facet.instance_methods.each do |name|
						instance_method = facet.instance_method(name)
						
						# Only memoize methods with no arguments:
						if instance_method.arity == 0
							keys << name
							
							evaluator.define_method(name) do
								@cache[name] ||= super()
							end
						end
					end
					
					# This lists all zero-argument methods:
					evaluator.define_method(:keys){keys}
					
					return evaluator.new
				end
				
				# Initialize a new evaluator.
				def initialize
					@cache = {}
				end
				
				# Inspect representation of the evaluator.
				# @returns [String] A string representation of the evaluator with its keys.
				def inspect
					"#<#{Evaluator} #{self.keys}>"
				end
				
				# Convert the evaluator to a hash.
				# @returns [Hash] A hash with all evaluated keys and values.
				def to_h
					# Ensure all keys are evaluated:
					self.keys.each do |name|
						self.__send__(name)
					end
					
					return @cache
				end
				
				# Convert the evaluator to JSON.
				# @parameter arguments [Array] Arguments passed to to_json.
				# @returns [String] A JSON representation of the evaluator.
				def to_json(...)
					self.to_h.to_json(...)
				end
				
				# Get value for a given key.
				# @parameter key [Symbol] The key to look up.
				# @returns [Object, nil] The value for the key, or nil if not found.
				def [](key)
					if self.key?(key)
						self.__send__(key)
					end
				end
				
				# Check if a key is available.
				# @parameter key [Symbol] The key to check.
				# @returns [Boolean] True if the key exists.
				def key?(key)
					self.keys.include?(key)
				end
			end
			
			# Create an evaluator for this environment.
			# @returns [Evaluator] A lazy evaluator for this environment.
			def evaluator
				return Evaluator.wrap(self)
			end
			
			# Convert the environment to a hash.
			# @returns [Hash] A hash representation of the environment.
			def to_h
				evaluator.to_h
			end
		end
	end
end
