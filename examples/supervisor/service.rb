#!/usr/bin/env async-service
# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024-2025, by Samuel Williams.

require "async/container/supervisor"
require "async/service/managed_service"
require "async/service/managed_environment"

class MemoryUsageService < Async::Service::ManagedService
	def run(instance, evaluator)
		things = []
		
		Async do
			while true
				sleep(rand)
				things << " " * 1024 * 1024 * 10
                                Console.info(self, "Allocated #{things.last.bytesize} bytes...")
			end
		ensure
			Fiber.blocking do
				Console.info(self, "Blocking for cleanup...")
				sleep
			ensure
				Console.info(self, "Cleanup complete.")
			end
		end
	end
end

service "memory-usage" do
	include Async::Service::ManagedEnvironment
	
	service_class MemoryUsageService
	
	count 40
	
	health_check_timeout 10
	
	include Async::Container::Supervisor::Supervised
end

service "supervisor" do
	include Async::Container::Supervisor::Environment
	
	monitors do
		[
			Async::Container::Supervisor::MemoryMonitor.new(
				# The interval at which to check for memory leaks.
				interval: 10,
				maximum_size_limit: 1024 * 1024 * 30,
				increase_limit: nil,
			)
		]
	end
end
