# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024-2025, by Samuel Williams.

require "async/service/environment"

module MyEnvironment
	def my_key
		"value"
	end
	
	def my_method(x, y)
		x + y
	end
end

describe Async::Service::Environment do
	it "must be provided a module" do
		expect{subject.new(Object)}.to raise_exception(ArgumentError)
	end
	
	it "can evaluate values" do
		environment = subject.build do
			my_key "value"
		end
		
		expect(environment.to_h).to have_keys(my_key: be == "value")
	end
	
	it "can use other methods" do
		environment = subject.build do |builder|
			builder.dir __dir__
		end
		
		expect(environment.to_h).to have_keys(dir: be == __dir__)
	end
	
	it "can evaluate methods" do
		environment = subject.build do
			include MyEnvironment
			my_key {my_method(1, 2)}
		end
		
		expect(environment.to_h).to have_keys(my_key: be == 3)
	end
	
	it "can evaluate nested values" do
		environment = subject.build do
			other_key "other value"
			my_key {other_key}
		end
		
		expect(environment.to_h).to have_keys(my_key: be == "other value")
	end
	
	it "can evaluate blocks" do
		environment = subject.build do
			my_key {"value"}
		end
		
		expect(environment.to_h).to have_keys(my_key: be == "value")
	end
	
	it "can evaluate blocks with previous value" do
		environment = subject.build(my_key: "value").with do
			my_key {"other value;" + super()}
		end
		
		expect(environment.to_h).to have_keys(my_key: be == "other value;value")
	end
	
	it "can include other environments" do
		my_service = subject.build do
			my_key "value"
		end
		
		environment = subject.build do
			include my_service
		end
		
		expect(environment.to_h).to have_keys(my_key: be == "value")
	end
	
	it "can include other modules" do
		environment = subject.build do
			include MyEnvironment
		end
		
		expect(environment.to_h).to have_keys(my_key: be == "value")
	end
	
	with "#evaluator" do
		it "can evaluate values" do
			environment = subject.build do
				my_proc {Object.new}
			end
			
			evaluator = environment.evaluator
			expect(evaluator.key?(:my_proc)).to be == true
			expect(evaluator.respond_to?(:my_proc)).to be == true
			expect(evaluator.my_proc).to be_a(Object)
			
			expect{evaluator.invalid_key}.to raise_exception(NoMethodError)
		end
		
		it "can generate JSON" do
			environment = subject.build do
				my_key "value"
			end
			
			expect(environment.evaluator.to_json).to be == '{"my_key":"value"}'
		end
		
		it "can access values using hash-like syntax" do
			environment = subject.build do
				my_key "value"
				other_key "other"
			end
			
			evaluator = environment.evaluator
			expect(evaluator[:my_key]).to be == "value"
			expect(evaluator[:other_key]).to be == "other"
			expect(evaluator[:nonexistent]).to be_nil
		end
	end
	
	with "Builder.for with Proc values" do
		it "can handle Proc values passed as keyword arguments" do
			environment = subject.build(my_key: ->{"proc_value"})
			
			expect(environment.to_h).to have_keys(my_key: be == "proc_value")
		end
	end
	
	with "Builder.for with facets" do
		it "can include facets passed as arguments" do
			environment = subject.build(MyEnvironment)
			
			expect(environment.to_h).to have_keys(my_key: be == "value")
		end
		
		it "can include multiple facets" do
			other_module = Module.new do
				def other_key
					"other_value"
				end
			end
			
			environment = subject.build(MyEnvironment, other_module)
			
			expect(environment.to_h).to have_keys(
				my_key: be == "value",
				other_key: be == "other_value"
			)
		end
	end
	
	with "Builder.include error cases" do
		it "raises ArgumentError when including non-module, non-includable object" do
			builder = Async::Service::Environment::Builder.new
			
			expect{builder.include(Object.new)
			}.to raise_exception(ArgumentError)
		end
	end
	
	with "#implements?" do
		it "can check if environment implements a module" do
			environment = subject.build do
				include MyEnvironment
			end
			
			expect(environment).to be(:implements?, MyEnvironment)
		end
		
		it "can check if environment implements a module" do
			environment = subject.build do
			end
			
			expect(environment).not.to be(:implements?, MyEnvironment)
		end
	end
end
