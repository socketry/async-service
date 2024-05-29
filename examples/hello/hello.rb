#!/usr/bin/env async-service

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
