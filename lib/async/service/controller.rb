# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024, by Samuel Williams.

require 'async/container/controller'

module Async
	module Service
		class Controller < Async::Container::Controller
			def initialize(services, **options)
				super(**options)
				
				@services = services
			end
			
			# Start all named services.
			def start
				@services.each do |service|
					service.start
				end
				
				super
			end
			
			# Setup all named services into the given container.
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
