# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024-2025, by Samuel Williams.

def initialize(context)
	super
	
	require "async/service/controller"
end

def run
	begin
		Bundler.require(:preload)
	rescue Bundler::GemfileNotFound
		# Ignore.
	end
	
	if Process.respond_to?(:warmup)
		Process.warmup
	elsif GC.respond_to?(:compact)
		GC.compact
	end
	
	controller.run
end

private

def controller
	configuration = context.lookup("async:service:configuration").instance.configuration
	
	return Async::Service::Controller.new(configuration.services)
end
