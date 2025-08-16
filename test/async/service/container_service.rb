# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025, by Samuel Williams.

require "async/service/container_service"
require "async/service/container_environment"

describe Async::Service::ContainerService do
	let(:configuration) do
		Async::Service::Configuration.build do
			service "test-container" do
				service_class Async::Service::ContainerService
				include Async::Service::ContainerEnvironment
				
				count 2
				health_check_timeout 5
			end
		end
	end
	
	let(:service) {configuration.services.first}
	
	it "can create a container service with container environment" do
		expect(service).to be_a(Async::Service::ContainerService)
		expect(service.name).to be == "test-container"
	end
	
	it "has access to container options from environment" do
		evaluator = service.environment.evaluator
		options = evaluator.container_options
		
		expect(options[:count]).to be == 2
		expect(options[:health_check_timeout]).to be == 5
		expect(options[:restart]).to be == true
	end
	
	it "can setup the container service" do
		container = Async::Container.new
		options_captured = nil
		
		# Mock the container.run method to capture the options
		mock(container) do |mock|
			mock.replace(:run) do |**options, &block|
				options_captured = options
				# We need to return something to prevent errors
				nil
			end
		end
		
		service.setup(container)
		
		# Verify the container options were passed correctly
		expect(options_captured).not.to be_nil
		expect(options_captured[:count]).to be == 2
		expect(options_captured[:health_check_timeout]).to be == 5
		expect(options_captured[:restart]).to be == true
	end
	
	with "custom container options" do
		let(:configuration) do
			Async::Service::Configuration.build do
				service "custom-container" do
					service_class Async::Service::ContainerService
					include Async::Service::ContainerEnvironment
					
					count 4
					health_check_timeout 60
				end
			end
		end
		
		it "uses custom container options" do
			evaluator = service.environment.evaluator
			options = evaluator.container_options
			
			expect(options[:count]).to be == 4
			expect(options[:health_check_timeout]).to be == 60
		end
	end
	
	with "disabled health check" do
		let(:configuration) do
			Async::Service::Configuration.build do
				service "no-health-check" do
					service_class Async::Service::ContainerService
					include Async::Service::ContainerEnvironment
					
					health_check_timeout nil
				end
			end
		end
		
		it "excludes health check timeout when nil" do
			evaluator = service.environment.evaluator
			options = evaluator.container_options
			
			expect(options).not.to have_keys(:health_check_timeout)
			expect(options[:restart]).to be == true
		end
	end
end
