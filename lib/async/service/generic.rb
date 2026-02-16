# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024-2026, by Samuel Williams.

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
				Console.debug(self){"Starting service #{self.name}..."}
			end
			
			# Setup the service into the specified container.
			# @parameter container [Async::Container::Generic]
			def setup(container)
				Console.debug(self){"Setting up service #{self.name}..."}
			end
			
			# Stop the service. Called after the container is stopped.
			def stop(graceful = true)
				Console.debug(self){"Stopping service #{self.name}..."}
			end
		end
	end
end
