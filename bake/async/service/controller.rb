# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024-2025, by Samuel Williams.

def initialize(context)
	super
	
	require "async/service/controller"
end

def run
	controller.run
end

private

def controller
	configuration = context.lookup("async:service:configuration").instance.configuration
	
	return configuration.make_controller
end
