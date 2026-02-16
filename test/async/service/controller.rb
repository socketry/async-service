# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025, by Samuel Williams.

require "async/service/controller"
require "async/service/generic"
require "async/service/environment"
require "async/container"

describe Async::Service::Controller do
	let(:environment1) do
		Async::Service::Environment.build do
			name "service1"
		end
	end
	
	let(:environment2) do
		Async::Service::Environment.build do
			name "service2"
		end
	end
	
	let(:service1) {Async::Service::Generic.new(environment1)}
	let(:service2) {Async::Service::Generic.new(environment2)}
	
	with ".for" do
		it "can create a controller from services" do
			controller = subject.for(service1, service2)
			
			expect(controller).to be_a(Async::Service::Controller)
			expect(controller.services).to have_attributes(size: be == 2)
			expect(controller.services).to be(:include?, service1)
			expect(controller.services).to be(:include?, service2)
		end
	end
	
	with "#start" do
		it "starts all services" do
			controller = subject.new([service1, service2])
			
			expect(service1).to receive(:start).and_return(nil)
			expect(service2).to receive(:start).and_return(nil)
			# We can't easily mock super, so we'll just verify services are called
			# The super call will happen but we can't verify it directly
			
			controller.start
		end
	end
	
	with "#setup" do
		it "sets up all services in container" do
			controller = subject.new([service1, service2])
			container = Async::Container.new
			
			expect(service1).to receive(:setup).with(container).and_return(nil)
			expect(service2).to receive(:setup).with(container).and_return(nil)
			# We can't easily mock super, but we can verify the result
			
			result = controller.setup(container)
			
			expect(result).to be == container
		end
	end
	
	with "#stop" do
		it "stops all services gracefully" do
			controller = subject.new([service1, service2])
			
			# Note: The controller calls service.stop without passing the graceful parameter
			expect(service1).to receive(:stop).and_return(nil)
			expect(service2).to receive(:stop).and_return(nil)
			# We can't easily mock super, but we can verify services are called
			
			controller.stop(true)
		end
		
		it "stops all services forcefully" do
			controller = subject.new([service1, service2])
			
			# Note: The controller calls service.stop without passing the graceful parameter
			expect(service1).to receive(:stop).and_return(nil)
			expect(service2).to receive(:stop).and_return(nil)
			
			controller.stop(false)
		end
		
		it "handles errors when stopping services" do
			controller = subject.new([service1, service2])
			error = StandardError.new("Service error")
			
			expect(service1).to receive(:stop).and_raise(error)
			expect(Console).to receive(:error).with(controller, error).and_return(nil)
			expect(service2).to receive(:stop).and_return(nil)
			
			# Should not raise exception
			controller.stop
		end
	end
end

