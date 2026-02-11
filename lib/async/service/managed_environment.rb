# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024-2025, by Samuel Williams.

# Compatibility shim for Async::Service::ManagedEnvironment
# Use Async::Service::Managed::Environment instead
require_relative "managed/environment"

module Async
	module Service
		# @deprecated Use {Managed::Environment} instead.
		ManagedEnvironment = Managed::Environment
	end
end

