# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024, by Samuel Williams.

module Async
	module Service
		class Environment
			class Builder < BasicObject
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
				
				def initialize(facet = ::Module.new)
					@facet = facet
				end
				
				def include(target)
					if target.class == ::Module
						@facet.include(target)
					elsif target.respond_to?(:included)
						target.included(@facet)
					else
						::Kernel.raise ::ArgumentError, "Cannot include #{target.inspect} into #{@facet.inspect}!"
					end
				end
				
				def method_missing(name, argument = nil, &block)
					if block
						@facet.define_method(name, &block)
					else
						@facet.define_method(name){argument}
					end
				end
				
				def respond_to_missing?(name, include_private = false)
					true
				end
			end
			
			def self.build(...)
				Environment.new(Builder.for(...))
			end
			
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
			
			def included(target)
				@parent&.included(target)
				target.include(@facet)
			end
			
			def with(...)
				return self.class.new(Builder.for(...), self)
			end
			
			def implements?(interface)
				@facet <= interface
			end
			
			# An evaluator is lazy read-only view of an environment. It memoizes all method calls.
			class Evaluator
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
					evaluator.define_method(:keys) {keys}
					
					return evaluator.new
				end
				
				def initialize
					@cache = {}
				end
				
				def inspect
					"#<#{Evaluator} #{self.keys}>"
				end
				
				def to_h
					# Ensure all keys are evaluated:
					self.keys.each do |name|
						self.__send__(name)
					end
					
					return @cache
				end
				
				def to_json(...)
					self.to_h.to_json(...)
				end
				
				def [](key)
					if self.key?(key)
						self.__send__(key)
					end
				end
				
				def key?(key)
					self.keys.include?(key)
				end
			end
			
			def evaluator
				return Evaluator.wrap(self)
			end
			
			def to_h
				evaluator.to_h
			end
		end
	end
end
