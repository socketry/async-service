# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025, by Samuel Williams.

require "async/service/configuration"
require "async/service/managed/environment"

describe Async::Service::Managed::Environment do
	let(:configuration) do
		Async::Service::Configuration.build do
			service "test-managed" do
				include Async::Service::Managed::Environment
				
				count 3
				health_check_timeout 10
			end
		end
	end
	
	let(:evaluator) {configuration.environments.first.evaluator}
	
	it "provides default container options" do
		options = evaluator.container_options
		
		expect(options[:restart]).to be == true
		expect(options[:count]).to be == 3
		expect(options[:health_check_timeout]).to be == 10
	end
	
	it "provides default count as nil" do
		configuration = Async::Service::Configuration.build do
			service "test-default" do
				include Async::Service::Managed::Environment
			end
		end
		
		evaluator = configuration.environments.first.evaluator
		expect(evaluator.count).to be_nil
	end
	
	it "provides default health_check_timeout as 30" do
		configuration = Async::Service::Configuration.build do
			service "test-default" do
				include Async::Service::Managed::Environment
			end
		end
		
		evaluator = configuration.environments.first.evaluator
		expect(evaluator.health_check_timeout).to be == 30
	end
	
	it "provides default preload as empty array" do
		expect(evaluator.preload).to be == []
	end
	
	it "compacts nil values from container_options" do
		configuration = Async::Service::Configuration.build do
			service "test-nil" do
				include Async::Service::Managed::Environment
				
				count nil
				health_check_timeout nil
			end
		end
		
		evaluator = configuration.environments.first.evaluator
		options = evaluator.container_options
		
		expect(options).not.to have_keys(:count, :health_check_timeout)
		expect(options[:restart]).to be == true
	end
end
