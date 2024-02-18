# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2023, by Samuel Williams.
# Copyright, 2019, by Sho Ito.

module Async
	module Service
		class Environment
			class Evaluator
				def self.for(initial, block)
					self.new(initial.dup).tap do |evaluator|
						evaluator.instance_eval(&block)
					end
				end
				
				def initialize(cache = Hash.new)
					@cache = cache
				end
				
				def [](key)
					@cache[key]
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
					
					if block_given?
						@cache[name] = lambda{block.call(previous)}
					elsif previous.is_a?(Array)
						@cache[name] = previous + Array(argument)
					elsif previous.is_a?(Hash)
						@cache[name] = previous.merge(argument)
					else
						@cache[name] = argument
					end
				end
				
				def to_h
					@cache
				end
			end
			
			def initialize(**initial, &block)
				@block = block
				@initial = initial
				@evaluator = nil
			end
			
			def evaluator
				Evaluator.for(@initial, @block)
			end
			
			class Roller
				def initialize(hash)
					@hash = hash
				end
				
				def object_value(value)
					case value
					when Array
						value.collect{|item| object_value(item)}.flatten
					when Symbol
						object_value(@hash[value])
					when Proc
						object_value(instance_exec(&value))
					else
						value
					end
				end
				
				def flatten
					@hash.transform_values(&self.method(:object_value))
				end
			end
			
			def flatten
				Roller.new(evaluator.to_h).flatten
			end
			
			alias to_h flatten
		end
	end
end
