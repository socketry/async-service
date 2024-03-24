# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024, by Samuel Williams.

require 'async/service/environment'

module MyEnvironment
	def my_key
		'value'
	end
	
	def my_method(x, y)
		x + y
	end
end

describe Async::Service::Environment do
	it 'must be provided a module' do
		expect{subject.new(Object)}.to raise_exception(ArgumentError)
	end
	
	it 'can evaluate values' do
		environment = subject.build do
			my_key 'value'
		end
		
		expect(environment.to_h).to have_keys(my_key: be == 'value')
	end
	
	it 'can use other methods' do
		environment = subject.build do |builder|
			builder.dir __dir__
		end
		
		expect(environment.to_h).to have_keys(dir: be == __dir__)
	end
	
	it 'can evaluate methods' do
		environment = subject.build do
			include MyEnvironment
			my_key {my_method(1, 2)}
		end
		
		expect(environment.to_h).to have_keys(my_key: be == 3)
	end
	
	it 'can evaluate nested values' do
		environment = subject.build do
			other_key 'other value'
			my_key {other_key}
		end
		
		expect(environment.to_h).to have_keys(my_key: be == 'other value')
	end
	
	it 'can evaluate blocks' do
		environment = subject.build do
			my_key {'value'}
		end
		
		expect(environment.to_h).to have_keys(my_key: be == 'value')
	end
	
	it 'can evaluate blocks with previous value' do
		environment = subject.build(my_key: 'value').with do
			my_key {'other value;' + super()}
		end
		
		expect(environment.to_h).to have_keys(my_key: be == 'other value;value')
	end
	
	it 'can include other environments' do
		my_service = subject.build do
			my_key 'value'
		end
		
		environment = subject.build do
			include my_service
		end
		
		expect(environment.to_h).to have_keys(my_key: be == 'value')
	end
	
	it 'can include other modules' do
		environment = subject.build do
			include MyEnvironment
		end
		
		expect(environment.to_h).to have_keys(my_key: be == 'value')
	end
	
	with '#evaluator' do
		it 'can evaluate values' do
			environment = subject.build do
				my_proc {Object.new}
			end
			
			evaluator = environment.evaluator
			expect(evaluator.key?(:my_proc)).to be == true
			expect(evaluator.respond_to?(:my_proc)).to be == true
			expect(evaluator.my_proc).to be_a(Object)
			
			expect{evaluator.invalid_key}.to raise_exception(NoMethodError)
		end
		
		it 'can generate JSON' do
			environment = subject.build do
				my_key 'value'
			end
			
			expect(environment.evaluator.to_json).to be == '{"my_key":"value"}'
		end
	end
	
	with '#implements?' do
		it 'can check if environment implements a module' do
			environment = subject.build do
				include MyEnvironment
			end
			
			expect(environment).to be(:implements?, MyEnvironment)
		end
		
		it 'can check if environment implements a module' do
			environment = subject.build do
			end
			
			expect(environment).not.to be(:implements?, MyEnvironment)
		end
	end
end
