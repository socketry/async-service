# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025-2026, by Samuel Williams.

require_relative "../generic"
require_relative "health_checker"

module Async
	module Service
		# @namespace
		module Managed
			# A managed service with built-in health checking, restart policies, and process title formatting.
			#
			# This is the recommended base class for most services that need robust lifecycle management.
			class Service < Generic
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
				
				# Called after the service has been prepared but before it starts running.
				#
				# Override this method to emit metrics, logs, or perform other actions when the service preparation is complete.
				#
				# @parameter instance [Async::Container::Instance] The container instance.
				# @parameter clock [Async::Clock] The monotonic start time from {Async::Clock.start}.
				def emit_prepared(instance, clock)
					# Override in subclasses as needed.
					# Console.info(self, "Prepared...", duration: clock.total)
				end
				
				# Called after the service has started running.
				#
				# Override this method to emit metrics, logs, or perform other actions when the service begins running.
				#
				# @parameter instance [Async::Container::Instance] The container instance.
				# @parameter clock [Async::Clock] The monotonic start time from {Async::Clock.start}.
				def emit_running(instance, clock)
					# Override in subclasses as needed.
					# Console.info(self, "Running...", duration: clock.total)
				end
				
				# Set up the container with health checking and process title formatting.
				# @parameter container [Async::Container] The container to configure.
				def setup(container)
					super
					
					container_options = @evaluator.container_options
					health_check_timeout = container_options[:health_check_timeout]
					
					container.run(**container_options) do |instance|
						clock = Async::Clock.start
						
						Async do
							evaluator = self.environment.evaluator
							server = nil
							
							health_checker(instance, health_check_timeout) do
								if server
									instance.name = format_title(evaluator, server)
								end
							end
							
							instance.status!("Preparing...")
							evaluator.prepare!(instance)
							emit_prepared(instance, clock)
							
							instance.status!("Running...")
							server = run(instance, evaluator)
							emit_running(instance, clock)
							
							instance.ready!
						end
					end
				end
			end
		end
	end
end
