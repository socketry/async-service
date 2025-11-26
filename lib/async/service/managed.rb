# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025, by Samuel Williams.

require_relative "managed/environment"
require_relative "managed/service"

module Async
	module Service
		# Managed services provide robust lifecycle management including health checking, restart policies, and process title formatting.
		#
		# This module contains components for building managed services that can run multiple instances with automatic restart and health monitoring.
		module Managed
		end
	end
end