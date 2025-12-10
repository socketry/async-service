# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024-2025, by Samuel Williams.

require "async/service/generic_service"
require "async/service/environment"
require "console"
require "async/container"

class MyService < Async::Service::GenericService
end

describe Async::Service::GenericService do
	let(:environment) {Async::Service::Environment.new}
	let(:service) {Async::Service::GenericService.new(environment)}
	
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
			service = Async::Service::GenericService.wrap(environment)
			expect(service).to be_a(MyService)
		end
	end
end
