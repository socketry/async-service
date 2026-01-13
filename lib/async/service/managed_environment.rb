# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025-2026, by Samuel Williams.

module Async
	module Service
		# Default configuration for managed services.
		#
		# This is provided not because it is required, but to offer a sensible default for production services, and to expose a consistent interface for service configuration.
		module ManagedEnvironment
			# Number of instances to start. By default, when `nil`, uses `Etc.nprocessors`.
			#
			# @returns [Integer | nil] The number of instances to start, or `nil` to use the default.
			def count
				nil
			end
			
			# The timeout duration for the startup. Set to `nil` to disable the startup timeout.
			#
			# @returns [Numeric | nil] The startup timeout in seconds.
			def startup_timeout
				nil
			end
			
			# The timeout duration for the health check. Set to `nil` to disable the health check.
			#
			# @returns [Numeric | nil] The health check timeout in seconds.
			def health_check_timeout
				30
			end
			
			# Options to use when creating the container, including `restart`, `count`, and `health_check_timeout`.
			#
			# @returns [Hash] The options for the container.
			def container_options
				{
					restart: true,
					count: self.count,
					startup_timeout: self.startup_timeout,
					health_check_timeout: self.health_check_timeout,
				}.compact
			end
			
			# Any scripts to preload before starting the service.
			#
			# @returns [Array(String)] The list of scripts to preload.
			def preload
				[]
			end
			
			# General tags for metrics, traces and logging.
			#
			# @returns [Array(String)] The tags for the service.
			def tags
				[]
			end
			
			# Prepare the instance for running the service.
			#
			# This is called before {Async::Service::ManagedService#run}.
			#
			# @parameter instance [Object] The container instance.
			def prepare!(instance)
				# No preparation required by default.
			end
		end
	end
end

