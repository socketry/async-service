# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025-2026, by Samuel Williams.

# Compatibility shim for Async::Service::GenericService
# Use Async::Service::Generic instead
require_relative "generic"

module Async
	module Service
		# @deprecated Use {Generic} instead.
		GenericService = Generic
	end
end
