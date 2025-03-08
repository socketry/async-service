# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025, by Samuel Williams.

require "async/service/generic"

module Async
	module Service
		class SleepService < Async::Service::Generic
			def setup(container)
				super
				
				container.run(count: 1, restart: true) do |instance|
					# Use log level:
					Console.logger.level = @environment.evaluator.log_level
					
					if container.statistics.failed?
						Console.debug(self, "Child process restarted #{container.statistics.restarts} times.")
					else
						Console.debug(self, "Child process started.")
					end

					instance.ready!

					while true
						sleep 1

						Console.debug(self, "Work")

						if rand < 0.1
							Console.debug(self, "Should exit...")
							sleep 0.5
							exit(1)
						end
					end
				end
			end	
		end
	end
end
