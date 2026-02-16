#!/usr/bin/env async-service
# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025-2026, by Samuel Williams.

# This file demonstrates running just the client component
# Run with: async-service examples/ipc/client.rb
# (Make sure server.rb is running first)

require "socket"

# Shared environment for IPC configuration
environment(:ipc) do
	# IPC socket path - defaults to service.ipc in current directory
	ipc_socket_path File.expand_path("service.ipc", Dir.pwd)
end

class IPCClient < Async::Service::Generic
	def setup(container)
		super
		
		container.run(count: 1, restart: true) do |instance|
			socket_path = evaluator.ipc_socket_path
			
			Console.info(self){"IPC Client starting - will connect to #{socket_path}"}
			instance.ready!
			
			while true
				begin
					# Connect to server
					client = UNIXSocket.new(socket_path)
					Console.info(self){"Connected to server"}
					
					# Read response
					response = client.readline.chomp
					puts "📨 Received: #{response}"
					
					client.close
					Console.info(self){"Connection closed"}
					
					# Wait before next connection
					sleep(2)
					
				rescue Errno::ENOENT
					Console.warn(self){"Server socket not found at #{socket_path}, retrying..."}
					sleep(3)
				rescue Errno::ECONNREFUSED
					Console.warn(self){"Connection refused, server may not be ready"}
					sleep(3)
				rescue => error
					Console.error(self, error)
					sleep(2)
				end
			end
		end
	end
end

service "ipc-client" do
	service_class IPCClient
	environment :ipc
end
