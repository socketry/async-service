# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024-2026, by Samuel Williams.

require "async/service/generic"
require "async/service/environment"
require "console"
require "async/container"

class MyService < Async::Service::Generic
end

describe Async::Service::Generic do
	let(:environment) {Async::Service::Environment.new}
	let(:service) {Async::Service::Generic.new(environment)}
	
	it "can start a generic service" do
		expect(Console).to receive(:debug).and_return(nil)
		
		service.start
	end
	
	it "can stop a generic service" do
		expect(Console).to receive(:debug).and_return(nil)
		
		service.stop
	end
	
	it "can setup a generic service" do
		expect(Console).to receive(:debug).and_return(nil)
		
		container = Async::Container.new
		service.setup(container)
	end
	
	with "service class" do
		let(:environment) do
			Async::Service::Environment.build do
				service_class MyService
			end
		end
		
		it "can wrap a service and construct the right class" do
			service = Async::Service::Generic.wrap(environment)
			expect(service).to be_a(MyService)
		end
	end
	
	with "make_service" do
		it "calls make_service with the environment" do
			received_environment = nil
			environment = Async::Service::Environment.build do
				make_service do |environment|
					received_environment = environment
					MyService.new(environment)
				end
			end
			
			service = Async::Service::Generic.wrap(environment)
			expect(service).to be_a(MyService)
			expect(received_environment).to be_equal(environment)
		end
		
		it "returns the service built by make_service" do
			sentinel = Object.new
			environment = Async::Service::Environment.build do
				make_service do |environment|
					sentinel
				end
			end
			
			expect(Async::Service::Generic.wrap(environment)).to be_equal(sentinel)
		end
	end
	
	with "make_service taking precedence over service_class" do
		let(:environment) do
			Async::Service::Environment.build do
				service_class MyService
				make_service do |environment|
					# Returns a plain Generic, not MyService
					Async::Service::Generic.new(environment)
				end
			end
		end
		
		it "uses make_service when both are defined" do
			service = Async::Service::Generic.wrap(environment)
			expect(service).to be_a(Async::Service::Generic)
			expect(service).not.to be_a(MyService)
		end
	end
end
