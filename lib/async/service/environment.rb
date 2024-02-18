# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2023, by Samuel Williams.
# Copyright, 2019, by Sho Ito.

module Async
	module Service
		class Environment
			class Builder < BasicObject
				def self.for(initial, block)
					builder = self.new(initial.dup)
					
					builder.instance_exec(&block)
					
					return builder
				end
				
				def initialize(cache = Hash.new)
					@cache = cache
				end
				
				def []=(key, value)
					@cache[key] = value
				end
				
				def include(target)
					target.to_h.each do |key, value|
						@cache[key] = value
					end
				end
				
				def method_missing(name, argument = nil, &block)
					previous = @cache[name]
					
					if block
						if block.arity == 0
							@cache[name] = block
						else
							# Bind the |previous| argument to the block:
							@cache[name] = ::Kernel.lambda{self.instance_exec(previous, &block)}
						end
					elsif previous.is_a?(::Array)
						@cache[name] = previous + argument
					elsif previous.is_a?(::Hash)
						@cache[name] = previous.merge(argument)
					else
						@cache[name] = argument
					end
				end
				
				def to_h
					@cache
				end
				
				def key?(key)
					@cache.key?(key)
				end
			end
			
			def initialize(**initial, &block)
				@block = block
				@initial = initial
			end
			
			def builder
				Builder.for(@initial, @block)
			end
			
			class Evaluator < BasicObject
				def initialize(cache)
					@cache = cache
				end
				
				private def __evaluate__(value)
					case value
					when ::Array
						value.collect{|item| __evaluate__(item)}
					when ::Hash
						value.transform_values{|item| __evaluate__(item)}
					# when ::Symbol
					# 	__evaluate__(@cache[value])
					when ::Proc
						__evaluate__(instance_exec(&value))
					else
						value
					end
				end
				
				def [](key)
					__evaluate__(@cache[key])
				end
				
				def respond_to?(name, include_all = false)
					@cache.key?(name) || super
				end
				
				def respond_to_missing?(name, include_all = false)
					@cache.key?(name) || super
				end
				
				def method_missing(name, ...)
					if @cache.key?(name)
						self[name]
					end
				end
				
				def to_h
					__evaluate__(@cache)
				end
			end
			
			def evaluator
				Evaluator.new(builder.to_h)
			end
			
			def to_h
				evaluator.to_h
			end
		end
	end
end
