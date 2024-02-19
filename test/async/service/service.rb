
require 'async/service/generic'
require 'console'
require 'async/container'

describe Async::Service::Generic do
	let(:environment) {Async::Service::Environment.new}
	let(:service) {Async::Service::Generic.new(environment)}
	
	it 'can start a generic service' do
		expect(Console).to receive(:debug).and_return(nil)
		
		service.start
	end
	
	it 'can stop a generic service' do
		expect(Console).to receive(:debug).and_return(nil)
		
		service.stop
	end
	
	it 'can setup a generic service' do
		expect(Console).to receive(:debug).and_return(nil)
		
		container = Async::Container.new
		service.setup(container)
	end
end
