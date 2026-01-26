# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025, by Samuel Williams.

require "async/service/health_checker"
require "async/service/managed_environment"
require "async/service/environment"
require "async"

require "sus/fixtures/async/scheduler_context"

class FakeInstance
	def initialize
		@updates = Thread::Queue.new
	end
	
	attr :updates
	
	def ready!
		@updates.push([:ready!, Time.now])
	end
	
	def healthy!
		@updates.push([:healthy!, Time.now])
	end
end

describe Async::Service::HealthChecker do
	include Sus::Fixtures::Async::SchedulerContext
	
	let(:environment) do
		Async::Service::Environment.build do
			include Async::Service::ManagedEnvironment
			health_check_timeout 10
		end
	end
	
	let(:service_class) do
		Class.new do
			include Async::Service::HealthChecker
			
			def initialize(environment)
				@evaluator = environment.evaluator
			end
			
			attr :evaluator
		end
	end
	
	let(:service) {service_class.new(environment)}
	let(:instance) {FakeInstance.new}
	
	with "#health_checker with timeout" do
		it "creates an async task that calls healthy! periodically" do
			health_checker_task = service.health_checker(instance, 0.1)
			
			# Wait a bit to let the health checker run
			sleep(0.15)
			
			health_checker_task.stop
			
			# Should have called healthy! at least once
			update = instance.updates.pop
			expect(update[0]).to be == :healthy!
			expect(update[1]).to be_a(Time)
		end
		
		it "yields the instance if a block is given" do
			block_called = false
			instance_passed = nil
			
			health_checker_task = service.health_checker(instance, 0.1) do |inst|
				block_called = true
				instance_passed = inst
			end
			
			# Wait a bit to let the health checker run
			sleep(0.15)
			
			health_checker_task.stop
			
			expect(block_called).to be == true
			expect(instance_passed).to be == instance
		end
		
		it "sleeps for half the timeout duration" do
			health_checker_task = service.health_checker(instance, 0.2)
			
			# Wait for at least two cycles
			sleep(0.25)
			
			health_checker_task.stop
			
			# Collect all healthy! calls
			healthy_times = []
			while instance.updates.size > 0
				update = instance.updates.pop
				expect(update[0]).to be == :healthy!
				healthy_times << update[1]
			end
			
			# Should have called healthy! multiple times
			expect(healthy_times.size).to be >= 2
			
			# Check that calls are approximately spaced by timeout/2
			if healthy_times.size >= 2
				intervals = healthy_times.each_cons(2).map{|a, b| b - a}
				# Each interval should be approximately timeout/2 (0.1 seconds)
				intervals.each do |interval|
					expect(interval).to be >= 0.08
					expect(interval).to be <= 0.12
				end
			end
		end
	end
	
	with "#health_checker without timeout" do
		it "calls healthy! immediately" do
			service.health_checker(instance, nil)
			
			# Should be called immediately, no need to wait
			update = instance.updates.pop
			expect(update[0]).to be == :healthy!
			expect(update[1]).to be_a(Time)
		end
		
		it "yields the instance if a block is given" do
			block_called = false
			instance_passed = nil
			
			service.health_checker(instance, nil) do |inst|
				block_called = true
				instance_passed = inst
			end
			
			expect(block_called).to be == true
			expect(instance_passed).to be == instance
			# healthy! should still be called
			update = instance.updates.pop
			expect(update[0]).to be == :healthy!
			expect(update[1]).to be_a(Time)
		end
		
		it "does not create an async task" do
			parent_task = Async::Task.current
			async_called = false
			
			mock(parent_task) do |mock|
				mock.replace(:async) do |transient: false, &block|
					async_called = true
					block.call
				end
			end
			
			service.health_checker(instance, nil, parent: parent_task)
			
			expect(async_called).to be == false
			# healthy! should still be called
			update = instance.updates.pop
			expect(update[0]).to be == :healthy!
			expect(update[1]).to be_a(Time)
		end
	end
	
	with "#health_checker with default timeout from evaluator" do
		it "uses the timeout from evaluator when not specified" do
			# Use default timeout from evaluator (10 seconds)
			health_checker_task = service.health_checker(instance)
			
			# Wait a short time - with 10 second timeout, should sleep for 5 seconds
			# So we won't see multiple calls in a short time
			sleep(0.1)
			
			health_checker_task.stop
			
			# Should have called healthy! at least once
			update = instance.updates.pop
			expect(update[0]).to be == :healthy!
			expect(update[1]).to be_a(Time)
		end
	end
end

