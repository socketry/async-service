#!/usr/bin/env async-service
# frozen_string_literal: trueb

# Released under the MIT License.
# Copyright, 2024, by Samuel Williams.

LogLevel = environment do
	log_level :info
end

require "async/service/sleep_service"

service "sleep" do
	include LogLevel
	
	authority {self.name}
	middleware {Object.new}
	
	service_class Async::Service::SleepService
end

# A 2nd service:
# service "sleep-2" do
# 	include LogLevel
# 	service SleepService
# end
