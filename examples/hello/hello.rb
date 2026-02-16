#!/usr/bin/env async-service
# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024-2026, by Samuel Williams.

class SleepService < Async::Service::Generic
	def setup(container)
		super
		
		container.run(count: 1, restart: true) do |instance|
			instance.ready!
			
			while true
				puts "Hello World!"
				sleep 1
			end
		end
	end
end

service "sleep" do
	service_class SleepService
end
