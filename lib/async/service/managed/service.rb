# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025, by Samuel Williams.

require_relative "../generic"
require_relative "../formatting"
require_relative "health_checker"

module Async
	module Service
		module Managed
			# A managed service with built-in health checking, restart policies, and process title formatting.
			#
			# This is the recommended base class for most services that need robust lifecycle management.
			class Service < Generic
				include Formatting
				include HealthChecker
				
				private def format_title(evaluator, server)
					"#{evaluator.name} #{server.to_s}"
				end
				
				# Run the service logic.
				#
				# Override this method to implement your service. Return an object that represents the running service (e.g., a server, task, or worker pool) for health checking.
				#
				# @parameter instance [Object] The container instance.
				# @parameter evaluator [Environment::Evaluator] The environment evaluator.
				# @returns [Object] The service object (server, task, etc.)
				def run(instance, evaluator)
					Async do
						sleep
					end
				end
				
				# Preload any resources specified by the environment.
				def preload!
					if scripts = @evaluator.preload
						root = @evaluator.root
						scripts = Array(scripts)
						
						scripts.each do |path|
							Console.info(self){"Preloading #{path}..."}
							full_path = File.expand_path(path, root)
							require(full_path)
						end
					end
				rescue StandardError, LoadError => error
					Console.warn(self, "Service preload failed!", error)
				end
				
				# Start the service, including preloading resources.
				def start
					preload!
					
					super
				end
				
				# Set up the container with health checking and process title formatting.
				# @parameter container [Async::Container] The container to configure.
				def setup(container)
					super
					
					container_options = @evaluator.container_options
					health_check_timeout = container_options[:health_check_timeout]
					
					container.run(**container_options) do |instance|
						evaluator = self.environment.evaluator
						
						server = run(instance, evaluator)
						
						health_checker(instance) do
							instance.name = format_title(evaluator, server)
						end
					end
				end	
			end
		end
	end
end

