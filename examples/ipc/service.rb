#!/usr/bin/env async-service
# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025, by Samuel Williams.

require "socket"
require "async"
require "async/service/container_service"
require "async/service/container_environment"

# Server service that listens on a Unix domain socket and responds with "Hello World"
class IPCServer < Async::Service::ContainerService
	def run(instance, evaluator)
		socket_path = evaluator.ipc_socket_path
		
		# Clean up any existing socket
		File.unlink(socket_path) if File.exist?(socket_path)
		
		# Create Unix domain socket server
		server = UNIXServer.new(socket_path)
		
		Console.info(self) {"IPC Server listening on #{socket_path}"}
		instance.ready!
		
		begin
			while true
				# Accept incoming connections
				client = server.accept
				Console.info(self) {"Client connected"}
				
				# Send greeting
				client.write("Hello World\n")
				client.close
				
				Console.info(self) {"Sent greeting and closed connection"}
			end
		rescue => error
			Console.error(self, error)
		ensure
			server&.close
			File.unlink(socket_path) if File.exist?(socket_path)
		end
		
		return server
	end
end

# Client service that periodically connects to the server
class IPCClient < Async::Service::ContainerService
	def run(instance, evaluator)
		socket_path = evaluator.ipc_socket_path
		timeout = evaluator.ipc_connection_timeout
		
		Console.info(self) {"IPC Client starting - will connect to #{socket_path}"}
		instance.ready!
		
		Async do |task|
			while true
				begin
					# Wait a bit before first connection attempt
					task.sleep(2)
					
					# Connect to server
					client = UNIXSocket.new(socket_path)
					Console.info(self) {"Connected to server"}
					
					# Read response
					response = client.readline.chomp
					puts "Received from server: #{response}"
					
					client.close
					Console.info(self) {"Connection closed"}
					
					# Wait before next connection
					task.sleep(3)
					
				rescue Errno::ENOENT
					Console.warn(self) {"Server socket not found at #{socket_path}, retrying..."}
					task.sleep(2)
				rescue => error
					Console.error(self, error)
					task.sleep(2)
				end
			end
		end
	end
end

module IPCEnvironment
	include Async::Service::ContainerEnvironment
	
	def ipc_socket_path
		File.expand_path("service.ipc", Dir.pwd)
	end
	
	def ipc_connection_timeout
		5.0
	end
	
	# Override to use only 1 instance for both services.
	def count
		1
	end
end

# Define both services using the shared IPC environment:
service "ipc-server" do
	service_class IPCServer
	include IPCEnvironment
end

service "ipc-client" do
	service_class IPCClient
	include IPCEnvironment
end
