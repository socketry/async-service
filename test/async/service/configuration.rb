# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024-2026, by Samuel Williams.

require "async/service/configuration"
require "async/service/good_interface"
require "async/container/threaded"

describe Async::Service::Configuration do
	with ".build" do
		it "can create a new configuration" do
			configuration = subject.build do
				service "test" do
					name "value"
				end
			end
			
			expect(configuration.environments).to have_attributes(
				size: be == 1
			)
		end
	end
	
	with ".for" do
		it "can create a new configuration" do
			environment = Async::Service::Environment.new
			configuration = subject.for(environment)
			
			expect(configuration.environments).to be(:include?, environment)
		end
	end
	
	with ".load" do
		let(:configuration_path) {File.join(__dir__, ".configurations", "null.rb")}
		
		it "can load configuration from file paths" do
			configuration = subject.load([configuration_path])
			
			expect(configuration).not.to be(:empty?)
			expect(configuration.environments.first.evaluator.name).to be == "null"
		end
		
		it "can load with empty array" do
			configuration = subject.load([])
			
			expect(configuration).to be_a(Async::Service::Configuration)
			expect(configuration).to be(:empty?)
		end
	end
	
	with "null serice configuration file" do
		let(:configuration_path) {File.join(__dir__, ".configurations", "null.rb")}
		
		let(:configuration) do
			subject.new.tap do |configuration|
				configuration.load_file(configuration_path)
			end
		end
		
		it "can load configuration" do
			expect(configuration).not.to be(:empty?)
			
			environment = configuration.environments.first
			evaluator = environment.evaluator
			expect(evaluator.name).to be == "null"
			
			expect(configuration.services.to_a).to be(:empty?)
		end
	end
	
	with "implementing service configuration file" do
		let(:configuration_path) {File.join(__dir__, ".configurations", "implementing.rb")}
		
		let(:configuration) do
			subject.new.tap do |configuration|
				configuration.load_file(configuration_path)
			end
		end
		
		it "can select services by implementing module" do
			expect(configuration).not.to be(:empty?)
			
			expect(configuration.services(implementing: Async::Service::GoodInterface).to_a).not.to be(:empty?)
		end
	end
	
	with "sleep service configuration file" do
		let(:configuration_path) {File.join(__dir__, ".configurations", "sleep.rb")}
		let(:configuration_root) {File.join(File.realpath(__dir__), ".configurations")}
		
		let(:configuration) do
			subject.new.tap do |configuration|
				configuration.load_file(configuration_path)
			end
		end
		
		it "can load configuration" do
			expect(configuration).not.to be(:empty?)
			
			environment = configuration.environments.first
			evaluator = environment.evaluator
			expect(evaluator.name).to be == "sleep"
			expect(evaluator.log_level).to be == :info
			
			expect(configuration.services.to_a).not.to be(:empty?)
			service = configuration.services.first
			
			expect(service.name).to be == "sleep"
			expect(service.to_h).to have_keys(
				name: be == "sleep",
				root: be == configuration_root,
			)
		end
		
		it "evaluates the value multiple times" do
			environment = configuration.environments.first
			evaluator = environment.evaluator
			
			middleware = evaluator.middleware
			expect(environment.evaluator.middleware).not.to be_equal(middleware)
		end
		
		it "can create a controller" do
			controller = configuration.make_controller
			expect(controller).to be_a(Async::Service::Controller)
			
			expect(controller.services).to have_attributes(
				size: be == 1
			)
		end
		
		it "make_controller returns controller with policy" do
			controller = configuration.make_controller
			
			expect(controller.make_policy).to be_a(Async::Container::Policy)
		end
		
		it "make_controller respects container_class option" do
			custom_class = Async::Container::Threaded
			controller = configuration.make_controller(container_class: custom_class)
			
			expect(controller.container_class).to be == custom_class
		end
	end
	
	with "other configuration file" do
		let(:configuration_path) {File.join(__dir__, ".configurations", "other.rb")}
		
		let(:configuration) do
			subject.new.tap do |configuration|
				configuration.load_file(configuration_path)
			end
		end
		
		it "can load a different configuration" do
			expect(configuration).not.to be(:empty?)
			
			environment = configuration.environments.first
			evaluator = environment.evaluator
			expect(evaluator.name).to be == "sleep"
		end
	end
end
