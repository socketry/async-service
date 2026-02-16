# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024-2025, by Samuel Williams.

def initialize(context)
	super
	
	require "async/service/controller"
end

def run
	# Warm up the Ruby process by preloading gems and running GC.
	Async::Service::Controller.warmup
	
	controller.run
end

private

def controller
	configuration = context.lookup("async:service:configuration").instance.configuration
	
	return Async::Service::Controller.new(configuration.services)
end
