# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024-2025, by Samuel Williams.

require "async/container/controller"
require_relative "policy"

module Async
	module Service
		# Controls multiple services and their lifecycle.
		#
		# The controller manages starting, stopping, and monitoring multiple services
		# within containers. It extends Async::Container::Controller to provide
		# service-specific functionality.
		class Controller < Async::Container::Controller
			# Run a configuration of services.
			# @parameter configuration [Configuration] The service configuration to run.
			# @parameter options [Hash] Additional options for the controller.
			def self.run(configuration, **options)
				configuration.make_controller(**options).run
			end
			
			# Create a controller for the given services.
			# @parameter services [Array(Generic)] The services to control.
			# @parameter options [Hash] Additional options for the controller.
			# @returns [Controller] A new controller instance.
			def self.for(*services, **options)
				self.new(services, **options)
			end
			
			# Initialize a new controller with services.
			# @parameter services [Array(Generic)] The services to manage.
			# @parameter options [Hash] Options passed to the parent controller.
			def initialize(services, **options)
				super(**options)
				
				@services = services
			end
			
			# Warm up the Ruby process by preloading gems, running GC, and compacting memory.
			# This reduces startup latency and improves copy-on-write efficiency.
			def warmup
				begin
					require "bundler"
					Bundler.require(:preload)
				rescue Bundler::GemfileNotFound, LoadError
					# Ignore.
				end
				
				if ::Process.respond_to?(:warmup)
					::Process.warmup
				elsif ::GC.respond_to?(:compact)
					3.times{::GC.start}
					::GC.compact
				end
			end
			
			# All the services associated with this controller.
			# @attribute [Array(Async::Service::Generic)]
			attr :services
			
			# Create a policy for managing child lifecycle events.
			# @returns [Policy] The service-level policy with failure rate monitoring.
			def make_policy
				Policy::DEFAULT
			end
			
			# Start all named services.
			def start
				@services.each do |service|
					service.start
				end
				
				super
				
				self.warmup
			end
			
			# Setup all services into the given container.
			#
			# @parameter container [Async::Container::Generic]
			def setup(container)
				super
				
				@services.each do |service|
					service.setup(container)
				end
				
				return container
			end
			
			# Stop all named services.
			def stop(graceful = true)
				@services.each do |service|
					begin
						service.stop
					rescue => error
						Console.error(self, error)
					end
				end
				
				super
			end
		end
	end
end
