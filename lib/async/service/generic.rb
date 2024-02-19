# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024, by Samuel Williams.

module Async
	module Service
		# Captures the stateful behaviour of a specific service.
		# Specifies the interfaces required by derived classes.
		#
		# Designed to be invoked within an {Async::Controller::Container}.
		class Generic
			# Convert the given environment into a service if possible.
			# @parameter environment [Build::Environment] The environment to use to construct the service.
			def self.wrap(environment)
				evaluator = environment.evaluator
				service = evaluator.service || self
				
				return service.new(environment)
			end
			
			# Initialize the service from the given environment.
			# @parameter environment [Build::Environment]
			def initialize(environment)
				@environment = environment
				@evaluator = @environment.evaluator
			end
			
			def to_h
				@evaluator.to_h
			end
			
			# The name of the service - used for informational purposes like logging.
			# e.g. `myapp.com`.
			def name
				@evaluator.name
			end
			
			# Start the service.
			def start
				Console.debug(self) {"Starting service #{self.name}..."}
			end
			
			# Setup the service into the specified container.
			# @parameter container [Async::Container::Generic]
			def setup(container)
				Console.debug(self) {"Setting up service #{self.name}..."}
			end
			
			# Stop the service.
			def stop(graceful = true)
				Console.debug(self) {"Stopping service #{self.name}..."}
			end
		end
	end
end
