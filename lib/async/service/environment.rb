# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024, by Samuel Williams.

module Async
	module Service
		class Environment
			class Builder < BasicObject
				def self.for(facet = ::Module.new, **values, &block)
					builder = self.new(facet)
					
					values.each do |key, value|
						if value.is_a?(::Proc)
							facet.define_method(key, &value)
						else
							facet.define_method(key){value}
						end
					end
					
					builder.instance_exec(&block) if block_given?
					
					return facet
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
			end
			
			def self.build(...)
				Environment.new(Builder.for(...))
			end
			
			def initialize(facet = ::Module.new, parent = nil)
				@facet = facet
				@parent = parent
			end
			
			def included(target)
				@parent&.included(target)
				target.include(@facet)
			end
			
			def with(...)
				return self.class.new(Builder.for(...), self)
			end
			
			# An evaluator is lazy read-only view of an environment. It memoizes all method calls.
			class Evaluator
				def self.wrap(environment)
					evaluator = ::Class.new(self)
					
					facet = ::Module.new
					environment.included(facet)
					
					evaluator.include(facet)
					
					# Memoize all instance methods:
					facet.instance_methods.each do |name|
						evaluator.define_method(name) do
							@cache[name] ||= super()
						end
					end
					
					evaluator.define_method(:keys) do
						facet.instance_methods
					end
					
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
				
				def [](key)
					self.__send__(key)
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
