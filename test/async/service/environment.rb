# frozen_string_literal: true

require 'async/service/environment'

describe Async::Service::Environment do
	it 'can evaluate values' do
		environment = subject.new do
			my_key 'value'
		end
		
		expect(environment.to_h).to have_keys(my_key: be == 'value')
	end
	
	it 'can evaluate nested values' do
		environment = subject.new do
			other_key 'other value'
			my_key :other_key
		end
		
		expect(environment.to_h).to have_keys(my_key: be == 'other value')
	end
	
	it 'can evaluate blocks' do
		environment = subject.new do
			my_key {'value'}
		end
		
		expect(environment.to_h).to have_keys(my_key: be == 'value')
	end
	
	it 'can evaluate blocks with previous value' do
		environment = subject.new do
			my_key 'value'
			my_key {|previous| 'other value;' + previous}
		end
		
		expect(environment.to_h).to have_keys(my_key: be == 'other value;value')
	end
	
	it 'can merge arrays' do
		environment = subject.new do
			my_key ['a', 'b']
			my_key ['c', 'd']
		end
		
		expect(environment.to_h).to have_keys(my_key: be == ['a', 'b', 'c', 'd'])
	end
	
	it 'can merge hashes' do
		environment = subject.new do
			my_key a: 1, b: 2
			my_key b: 3, c: 4
		end
		
		expect(environment.to_h).to have_keys(my_key: be == {a: 1, b: 3, c: 4})
	end
	
	it 'can include other environments' do
		my_service = subject.new do
			my_key 'value'
		end
		
		environment = subject.new do
			include my_service
		end
		
		expect(environment.to_h).to have_keys(my_key: be == 'value')
	end
end
