# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025-2026, by Samuel Williams.

# Compatibility shim for Async::Service::HealthChecker
# Use Async::Service::Managed::HealthChecker instead
require_relative "managed/health_checker"

module Async
	module Service
		# @deprecated Use {Managed::HealthChecker} instead.
		HealthChecker = Managed::HealthChecker
	end
end

