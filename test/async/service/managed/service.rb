# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025-2026, by Samuel Williams.

require "async/service/configuration"
require "async/service/managed/service"
require "async/service/managed/environment"
require "async/container"
require "async"

require "sus/fixtures/async/scheduler_context"

describe Async::Service::Managed::Service do
	let(:configuration) do
		Async::Service::Configuration.build do
			service "test-container" do
				service_class Async::Service::Managed::Service
				include Async::Service::Managed::Environment
				
				count 2
				health_check_timeout 5
			end
		end
	end
	
	let(:service) {configuration.services.first}
	
	it "can create a managed service with managed environment" do
		expect(service).to be_a(Async::Service::Managed::Service)
		expect(service.name).to be == "test-container"
	end
	
	it "has access to container options from environment" do
		evaluator = service.environment.evaluator
		options = evaluator.container_options
		
		expect(options[:count]).to be == 2
		expect(options[:health_check_timeout]).to be == 5
		expect(options[:restart]).to be == true
	end
	
	it "can setup the managed service" do
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
	
	with "integration test" do
		include Sus::Fixtures::Async::SchedulerContext
		
		it "executes the container block with async context and health checking" do
			container = Async::Container.new
			block_executed = false
			health_checker_called = false
			instance_ready_called = false
			
			# Create a mock instance that tracks ready! calls
			mock_instance = Object.new
			def mock_instance.ready!
				@ready_called = true
			end
			
			def mock_instance.status!(text)
				# status! is called during startup but doesn't need to be tracked
			end
			
			def mock_instance.ready_called?
				@ready_called || false
			end
			
			def mock_instance.name=(value)
				@name = value
			end
			
			def mock_instance.name
				@name
			end
			
			# Mock container.run to actually execute the block
			mock(container) do |mock|
				mock.replace(:run) do |**options, &block|
					# Execute the block in an async context (simulating what container does)
					Async do
						block.call(mock_instance)
					end
				end
			end
			
			# Override run to track execution
			service_class = Class.new(Async::Service::Managed::Service) do
				def run(instance, evaluator)
					@run_called = true
					super
				end
				
				def run_called?
					@run_called || false
				end
			end
			
			test_service = service_class.new(service.environment)
			
			# Setup should execute without errors
			expect{test_service.setup(container)
			}.not.to raise_exception
			
			# Give async tasks time to execute
			sleep(0.1)
			
			# Verify run was called
			expect(test_service.run_called?).to be == true
			
			# Verify health checker would have been called (it creates async tasks)
			# The instance should have been marked ready by the health checker
			expect(mock_instance.ready_called?).to be == true
		end
	end
	
	with "custom managed service options" do
		let(:configuration) do
			Async::Service::Configuration.build do
				service "custom-container" do
					service_class Async::Service::Managed::Service
					include Async::Service::Managed::Environment
					
					count 4
					health_check_timeout 60
				end
			end
		end
		
		it "uses custom managed service options" do
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
					service_class Async::Service::Managed::Service
					include Async::Service::Managed::Environment
					
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
	
	with "#start" do
		it "calls preload! and super" do
			expect(service).to receive(:preload!).and_return(nil)
			
			service.start
		end
	end
	
	with "#preload!" do
		let(:root) {__dir__}
		
		let(:environment) do
			Async::Service::Environment.build(root: root) do
				include Async::Service::Managed::Environment
				preload ["script1.rb", "script2.rb"]
			end
		end
		
		let(:service) {Async::Service::Managed::Service.new(environment)}
		
		it "calls require with expanded paths for each preload script" do
			required = Thread::Queue.new
			expect(Console).to receive(:info).twice.and_return(nil)
			expect(service).to receive(:require){|path| required.push(path)}
			
			service.preload!
			
			expect(required.pop).to be == File.expand_path("script1.rb", root)
			expect(required.pop).to be == File.expand_path("script2.rb", root)
		end
		
		it "handles single script as string" do
			environment = Async::Service::Environment.build(root: root) do
				include Async::Service::Managed::Environment
				preload "single.rb"
			end
			
			service = Async::Service::Managed::Service.new(environment)
			required = Thread::Queue.new
			
			expect(Console).to receive(:info).and_return(nil)
			expect(service).to receive(:require){|path| required.push(path)}
			
			service.preload!
			
			expect(required.pop).to be == File.expand_path("single.rb", root)
		end
		
		it "handles empty preload array" do
			environment = Async::Service::Environment.build(root: root) do
				include Async::Service::Managed::Environment
				preload []
			end
			
			service = Async::Service::Managed::Service.new(environment)
			expect(service).not.to receive(:require)
			
			service.preload!
		end
		
		it "handles nil preload" do
			environment = Async::Service::Environment.build(root: root) do
				include Async::Service::Managed::Environment
			end
			
			service = Async::Service::Managed::Service.new(environment)
			expect(service).not.to receive(:require)
			
			service.preload!
		end
		
		it "handles preload errors gracefully" do
			environment = Async::Service::Environment.build(root: root) do
				include Async::Service::Managed::Environment
				preload ["error.rb"]
			end
			
			service = Async::Service::Managed::Service.new(environment)
			error = LoadError.new("Cannot load such file")
			
			expect(Console).to receive(:info).and_return(nil)
			expect(service).to receive(:require).with(File.expand_path("error.rb", root)).and_raise(error)
			expect(Console).to receive(:warn).with(service, "Service preload failed!", error).and_return(nil)
			
			# Should not raise exception
			service.preload!
		end
	end
	
	with "#run" do
		include Sus::Fixtures::Async::SchedulerContext
		
		it "returns a sleeping task by default" do
			container_instance = Object.new
			evaluator = service.environment.evaluator
			
			task = service.run(container_instance, evaluator)
			expect(task).to be_a(Async::Task)
			
			task.stop
		end
	end
	
	with "integration test with controller" do
		let(:configuration) do
			Async::Service::Configuration.build do
				service "test-managed" do
					service_class Async::Service::Managed::Service
					include Async::Service::Managed::Environment
					
					count 1
					
					# Very short timeout to detect failures quickly:
					health_check_timeout 0.01
				end
			end
		end
		
		let(:test_service) {configuration.services.first}
		let(:controller) {Async::Service::Controller.for(test_service)}
		
		it "runs service with health checking and no restarts when async context is present" do
			container = Async::Container.new
			
			begin
				controller.setup(container)
				controller.start
				sleep(0.03)
			ensure
				controller.stop
				container.stop
			end
		end
	end
end
