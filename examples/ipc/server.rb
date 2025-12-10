#!/usr/bin/env async-service
# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025, by Samuel Williams.

# This file demonstrates running just the server component
# Run with: async-service examples/ipc/server.rb

require "socket"

# Shared environment for IPC configuration
environment(:ipc) do
	# IPC socket path - defaults to service.ipc in current directory
	ipc_socket_path File.expand_path("service.ipc", Dir.pwd)
end

class IPCServer < Async::Service::GenericService
	def setup(container)
		super
		
		container.run(count: 1, restart: true) do |instance|
			socket_path = evaluator.ipc_socket_path
			
			# Clean up any existing socket
			File.unlink(socket_path) if File.exist?(socket_path)
			
			# Create Unix domain socket server
			server = UNIXServer.new(socket_path)
			
			Console.info(self){"IPC Server listening on #{socket_path}"}
			instance.ready!
			
			begin
				while true
					# Accept incoming connections
					client = server.accept
					Console.info(self){"Client connected from PID #{client.peereid[0]}"}
					
					# Send greeting with timestamp
					timestamp = Time.now.strftime("%H:%M:%S")
					client.write("Hello World at #{timestamp}\n")
					client.close
					
					Console.info(self){"Sent greeting and closed connection"}
				end
			rescue => error
				Console.error(self, error)
			ensure
				server&.close
				File.unlink(socket_path) if File.exist?(socket_path)
			end
		end
	end
end

service "ipc-server" do
	service_class IPCServer
	environment :ipc
end
