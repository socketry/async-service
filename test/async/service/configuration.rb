# frozen_string_literal: true

require 'async/service/configuration'

describe Async::Service::Configuration do
	with 'test file' do
		it 'can load configuration' do
			configuration = subject.new
			
			configuration.load_file(File.join(__dir__, '.configurations', 'basic.rb'))
			
			expect(configuration).not.to be(:empty?)
			
			environment = configuration.environments.first
			evaluator = environment.evaluator
			expect(evaluator.name).to be == 'test'
			expect(evaluator.log_level).to be == :info
		end
		
		it 'evaluates the value multiple times' do
			configuration = subject.new
			
			configuration.load_file(File.join(__dir__, '.configurations', 'basic.rb'))
			
			environment = configuration.environments.first
			evaluator = environment.evaluator
			
			middleware = evaluator.middleware
			expect(evaluator.middleware).not.to be_equal(middleware)
		end
	end
end
