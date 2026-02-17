# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

require "async/container/policy"

module Async
	module Service
		# A service-level policy that extends the base container policy with failure rate monitoring.
		# This policy will stop the container if the failure rate exceeds a threshold.
		class Policy < Async::Container::Policy
			# Initialize the policy.
			# @parameter maximum_failures [Integer] The maximum number of failures allowed within the window.
			# @parameter window [Integer] The time window in seconds for counting failures.
			def initialize(maximum_failures: 6, window: 60)
				@maximum_failures = maximum_failures
				@window = window
				
				@failure_rate_threshold = maximum_failures.to_f / window
			end
			
			# The maximum number of failures allowed within the window.
			# @attribute [Integer]
			attr :maximum_failures
			
			# The time window in seconds for statistics tracking.
			# @attribute [Integer]
			attr :window
			
			# The failure rate threshold in failures per second.
			# @attribute [Float]
			attr :failure_rate_threshold
			
			# Create statistics for a container with the configured window.
			# @returns [Async::Container::Statistics] A new statistics instance.
			def make_statistics
				Async::Container::Statistics.new(window: @window)
			end
			
			# Called when a child exits. Monitors failure rate and stops the container if threshold is exceeded.
			# @parameter container [Async::Container::Generic] The container.
			# @parameter child [Child] The child process.
			# @parameter status [Process::Status] The exit status.
			# @parameter name [String] The name of the child.
			# @parameter key [Symbol] An optional key for the child.
			# @parameter options [Hash] Additional options for future extensibility.
			def child_exit(container, child, status, name:, key:, **options)
				unless success?(status)
					# Check failure rate after this failure is recorded
					rate = container.statistics.failure_rate.per_second
					
					if rate > @failure_rate_threshold
						# Only stop if container is not already stopping
						unless container.stopping?
							Console.error(self, "Failure rate exceeded threshold, stopping container!",
								rate: rate,
								threshold: @failure_rate_threshold
							)
							container.stop(true)
						end
					end
				end
			end
			
			# The default service policy instance.
			DEFAULT = self.new.freeze
		end
	end
end
