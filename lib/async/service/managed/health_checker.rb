# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025-2026, by Samuel Williams.

module Async
	module Service
		module Managed
			# A health checker for managed services.
			module HealthChecker
				# Start the health checker.
				#
				# If a timeout is specified, a transient child task will be scheduled which will mark the instance as healthy, sleep for half the health check duration (so that we guarantee that the health check runs in time), and then yield the instance if a block is given. This repeats indefinitely.
				#
				# If a timeout is not specified, the instance is marked as healthy immediately and no task is created. Any block given is ignored.
				#
				# @parameter instance [Object] The service instance to check.
				# @parameter timeout [Numeric] The timeout duration for the health check.
				# @parameter parent [Async::Task] The parent task to run the health checker in.
				# @yields {|instance| ...} If a block is given and a timeout is specified, it will be called with the service instance after each sleep interval.
				def health_checker(instance, timeout = @evaluator.health_check_timeout, parent: Async::Task.current, &block)
					if timeout
						parent.async(transient: true) do
							while true
								instance.healthy!
								
								sleep(timeout / 2.0)
								
								if block_given?
									yield(instance)
								end
							end
						end
					else
						instance.healthy!
					end
				end
			end
		end
	end
end
