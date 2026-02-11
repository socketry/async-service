# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024-2025, by Samuel Williams.

# Compatibility shim for Async::Service::ManagedService
# Use Async::Service::Managed::Service instead
require_relative "managed/service"

module Async
	module Service
		# @deprecated Use {Managed::Service} instead.
		ManagedService = Managed::Service
	end
end

