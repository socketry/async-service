# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024-2025, by Samuel Williams.

# Compatibility shim for Async::Service::Generic
# Use Async::Service::GenericService instead
require_relative "generic_service"

module Async
	module Service
		# @deprecated Use {GenericService} instead.
		Generic = GenericService
	end
end
