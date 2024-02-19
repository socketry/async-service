# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024, by Samuel Williams.

require 'async/service/configuration'

describe Async::Service::Configuration do
	with 'sleep service configuration file' do
		let(:configuration_path) {File.join(__dir__, '.configurations', 'sleep.rb')}
		
		let(:configuration) do
			subject.new.tap do |configuration|
				configuration.load_file(configuration_path)
			end
		end
		
		it 'can load configuration' do
			expect(configuration).not.to be(:empty?)
			
			environment = configuration.environments.first
			evaluator = environment.evaluator
			expect(evaluator.name).to be == 'sleep'
			expect(evaluator.log_level).to be == :info
			
			expect(configuration.services.to_a).not.to be(:empty?)
			service = configuration.services.first
			
			expect(service.name).to be == 'sleep'
			expect(service.to_h).to have_keys(
				name: be == 'sleep',
				root: be == File.dirname(configuration_path),
			)
		end
		
		it 'evaluates the value multiple times' do
			environment = configuration.environments.first
			evaluator = environment.evaluator
			
			middleware = evaluator.middleware
			expect(environment.evaluator.middleware).not.to be_equal(middleware)
		end
	end
end
