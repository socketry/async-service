# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025, by Samuel Williams.

module Async
	module Service
		# A health checker for managed services.
		module HealthChecker
			# Start the health checker.
			#
			# If a timeout is specified, a transient child task will be scheduled, which will yield the instance if a block is given, then mark the instance as ready, and finally sleep for half the health check duration (so that we guarantee that the health check runs in time).
			#
			# If a timeout is not specified, the health checker will yield the instance immediately and then mark the instance as ready.
			#
			# @parameter instance [Object] The service instance to check.
			# @parameter timeout [Numeric] The timeout duration for the health check.
			# @parameter parent [Async::Task] The parent task to run the health checker in.
			# @yields {|instance| ...} If a block is given, it will be called with the service instance at least once.
			def health_checker(instance, timeout = @evaluator.health_check_timeout, parent: Async::Task.current, &block)
				if timeout
					parent.async(transient: true) do
						while true
							if block_given?
								yield(instance)
							end
							
							# We deliberately create a fiber here, to confirm that fiber creation is working.
							# If something has gone wrong with fiber allocation, we will crash here, and that's okay.
							Fiber.new do
								instance.ready!
							end.resume
							
							sleep(timeout / 2)
						end
					end
				else
					if block_given?
						yield(instance)
					end
					
					instance.ready!
				end
			end
		end
	end
end

