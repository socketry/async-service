#!/usr/bin/env async-service
# frozen_string_literal: trueb

# Released under the MIT License.
# Copyright, 2025, by Samuel Williams.

require "async/service/good_interface"
require "async/service/sleep_service"

# A service without a service class, e.g. a no-op.
service "good-service" do
	include Async::Service::GoodInterface
	
	service_class Async::Service::SleepService
end

service "not-so-good-service" do
	service_class Async::Service::SleepService
end
