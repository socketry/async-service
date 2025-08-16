# frozen_string_literal: true

module Async
	module Service
		# Default configuration for container-based services.
		#
		# This is provided not because it is required, but to offer a sensible default for containerized applications, and to expose a consistent interface for service configuration.
		module ContainerEnvironment
			# Number of instances to start. By default, when `nil`, uses `Etc.nprocessors`.
			#
			# @returns [Integer | nil] The number of instances to start, or `nil` to use the default.
			def count
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
					health_check_timeout: self.health_check_timeout,
				}.compact
			end
			
			# Any scripts to preload before starting the server.
			#
			# @returns [Array(String)] The list of scripts to preload.
			def preload
				[]
			end
		end
	end
end
