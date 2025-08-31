# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025, by Samuel Williams.

require "string/format"

module Async
	module Service
		# Formatting utilities for service titles.
		#
		# Services need meaningful process/thread names for monitoring and debugging. This module provides consistent formatting for common service metrics like connection counts, request ratios, and load values in process titles.
		#
		# It is expected you will include these into your service class and use them to update the `instance.name` in the health check.
		#
		# @deprecated Use {String::Format} directly.
		module Formatting
			# Format a count into a human-readable string.
			# @parameter value [Numeric] The count to format.
			# @parameter units [Array] The units to use for formatting (default: String::Format::UNITS).
			# @returns [String] A formatted string representing the count.
			def format_count(value, units = String::Format::UNITS)
				String::Format.count(value, units)
			end
			
			module_function :format_count
			
			# Format a ratio as "current/total" with human-readable counts.
			# @parameter current [Numeric] The current value.
			# @parameter total [Numeric] The total value.
			# @returns [String] A formatted ratio string.
			def format_ratio(current, total)
				String::Format.ratio(current, total)
			end
			
			module_function :format_ratio
			
			# Format a load value as a decimal with specified precision.
			# @parameter load [Numeric] The load value (typically 0.0 to 1.0+).
			# @returns [String] A formatted load string.
			def format_load(load)
				String::Format.decimal(load)
			end
			
			module_function :format_load
			
			# Format multiple statistics into a compact string.
			# @parameter pairs [Hash] Hash of statistic names to values or [current, total] arrays.
			# @returns [String] A formatted statistics string.
			def format_statistics(**pairs)
				String::Format.statistics(pairs)
			end
			
			module_function :format_statistics
		end
	end
end
