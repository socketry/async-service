# frozen_string_literal: true

require 'async/service/configuration'

describe Async::Service::Configuration do
	with 'test file' do
		it 'can load configuration' do
			configuration = subject.new
			
			configuration.load_file(File.join(__dir__, '.configurations', 'basic.rb'))
			
			expect(configuration).not.to be(:empty?)
			
			service = configuration.services.first
			expect(service).to be_a(Async::Service::Generic)
		end
	end
end
