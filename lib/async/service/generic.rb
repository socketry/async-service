# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024-2025, by Samuel Williams.

module Async
	module Service
		# Captures the stateful behaviour of a specific service.
		# Specifies the interfaces required by derived classes.
		#
		# Designed to be invoked within an {Async::Controller::Container}.
		class Generic
			# Convert the given environment into a service if possible.
			# @parameter environment [Environment] The environment to use to construct the service.
			# @returns [Generic | Nil] The constructed service if the environment specifies a service class.
			def self.wrap(environment)
				evaluator = environment.evaluator
				
				if evaluator.key?(:service_class)
					if service_class = evaluator.service_class
						return service_class.new(environment, evaluator)
					end
				end
			end
			
			# Initialize the service from the given environment.
			# @parameter environment [Environment]
			def initialize(environment, evaluator = environment.evaluator)
				@environment = environment
				@evaluator = evaluator
			end
			
			# @attribute [Environment] The environment which is used to configure the service.
			attr :environment
			
			# Convert the service evaluator to a hash.
			# @returns [Hash] A hash representation of the evaluator.
			def to_h
				@evaluator.to_h
			end
			
			# The name of the service - used for informational purposes like logging.
			# e.g. `myapp.com`.
			def name
				@evaluator.name
			end
			
			# Start the service. Called before the container setup.
			def start
				Console.debug(self) {"Starting service #{self.name}..."}
			end
			
			# Setup the service into the specified container.
			# @parameter container [Async::Container::Generic]
			def setup(container)
				Console.debug(self) {"Setting up service #{self.name}..."}
			end
			
			# Stop the service. Called after the container is stopped.
			def stop(graceful = true)
				Console.debug(self) {"Stopping service #{self.name}..."}
			end
			
			protected
			
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
							
							instance.ready!
							
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
