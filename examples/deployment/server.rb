#!/usr/bin/env async-service
# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025-2026, by Samuel Williams.

require "async/http"
require "async/service/managed/service"
require "async/service/managed/environment"

class WebService < Async::Service::Managed::Service
	def start
		super
		@endpoint = @evaluator.endpoint
		@bound_endpoint = Sync{@endpoint.bound}
	end
	
	def stop
		@endpoint = nil
		@bound_endpoint&.close
		super
	end
	
	def run(instance, evaluator)
		Console.info(self){"Starting web server on #{@endpoint}"}
		
		server = Async::HTTP::Server.for(@bound_endpoint, protocol: @endpoint.protocol, scheme: @endpoint.scheme) do |request|
			Protocol::HTTP::Response[200, {}, ["Hello, World!"]]
		end
		
		instance.ready!
		server.run
	end
end

module WebEnvironment
	include Async::Service::Managed::Environment
	
	def endpoint
		Async::HTTP::Endpoint.parse("http://0.0.0.0:3000")
	end
end

service "web" do
	service_class WebService
	include WebEnvironment
end
