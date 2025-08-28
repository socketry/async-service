# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025, by Samuel Williams.

module Async
	module Service
		# Formatting utilities for service titles.
		#
		# Services need meaningful process/thread names for monitoring and debugging. This module provides consistent formatting for common service metrics like connection counts, request ratios, and load values in process titles.
		#
		# It is expected you will include these into your service class and use them to update the `instance.name` in the health check.
		module Formatting
			UNITS = [nil, "K", "M", "B", "T", "P", "E", "Z", "Y"]
			
			# Format a count into a human-readable string.
			# @parameter value [Numeric] The count to format.
			# @parameter units [Array] The units to use for formatting (default: UNITS).
			# @returns [String] A formatted string representing the count.
			def format_count(value, units = UNITS)
				value = value
				index = 0
				limit = units.size - 1
				
				# Handle negative numbers by working with absolute value:
				negative = value < 0
				value = value.abs
				
				while value >= 1000 and index < limit
					value = value / 1000.0
					index += 1
				end
				
				result = String.new
				result << "-" if negative
				result << value.round(2).to_s
				result << units[index].to_s if units[index]
				
				return result
			end
			
			module_function :format_count
			
			# Format a ratio as "current/total" with human-readable counts.
			# @parameter current [Numeric] The current value.
			# @parameter total [Numeric] The total value.
			# @returns [String] A formatted ratio string.
			def format_ratio(current, total)
				"#{format_count(current)}/#{format_count(total)}"
			end
			
			module_function :format_ratio
			
			# Format a load value as a decimal with specified precision.
			# @parameter load [Numeric] The load value (typically 0.0 to 1.0+).
			# @returns [String] A formatted load string.
			def format_load(load)
				load.round(2).to_s
			end
			
			module_function :format_load
			
			# Format multiple statistics into a compact string.
			# @parameter stats [Hash] Hash of statistic names to values or [current, total] arrays.
			# @returns [String] A formatted statistics string.
			def format_statistics(**pairs)
				pairs.map do |key, value|
					case value
					when Array
						if value.length == 2
							"#{key.to_s.upcase}=#{format_ratio(value[0], value[1])}"
						else
							"#{key.to_s.upcase}=#{value.join('/')}"
						end
					else
						"#{key.to_s.upcase}=#{format_count(value)}"
					end
				end.join(" ")
			end
			
			module_function :format_statistics
		end
	end
end
