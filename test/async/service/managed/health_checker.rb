# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025, by Samuel Williams.

require "async/service/managed/health_checker"
require "async/service/managed/environment"
require "async/service/environment"
require "async"

require "sus/fixtures/async/scheduler_context"

class FakeInstance
	def initialize
		@ready = Thread::Queue.new
	end
	
	attr :ready
	
	def ready!
		@ready.push(Time.now)
	end
end

describe Async::Service::Managed::HealthChecker do
	include Sus::Fixtures::Async::SchedulerContext
	
	let(:environment) do
		Async::Service::Environment.build do
			include Async::Service::Managed::Environment
			health_check_timeout 10
		end
	end
	
	let(:service_class) do
		Class.new do
			include Async::Service::Managed::HealthChecker
			
			def initialize(environment)
				@evaluator = environment.evaluator
			end
			
			attr :evaluator
		end
	end
	
	let(:service) {service_class.new(environment)}
	let(:instance) {FakeInstance.new}
	
	with "#health_checker with timeout" do
		it "creates an async task that calls ready! periodically" do
			health_checker_task = service.health_checker(instance, 0.1)
			
			# Wait a bit to let the health checker run
			sleep(0.15)
			
			health_checker_task.stop
			
			# Should have called ready! at least once
			expect(instance.ready.pop).to be_a(Time)
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
			
			# Collect all ready! calls
			ready_times = []
			while instance.ready.size > 0
				ready_times << instance.ready.pop
			end
			
			# Should have called ready! multiple times
			expect(ready_times.size).to be >= 2
			
			# Check that calls are approximately spaced by timeout/2
			if ready_times.size >= 2
				intervals = ready_times.each_cons(2).map{|a, b| b - a}
				# Each interval should be approximately timeout/2 (0.1 seconds)
				intervals.each do |interval|
					expect(interval).to be >= 0.08
					expect(interval).to be <= 0.12
				end
			end
		end
	end
	
	with "#health_checker without timeout" do
		it "calls ready! immediately" do
			service.health_checker(instance, nil)
			
			# Should be called immediately, no need to wait
			expect(instance.ready.pop).to be_a(Time)
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
			# ready! should still be called
			expect(instance.ready.pop).to be_a(Time)
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
			# ready! should still be called
			expect(instance.ready.pop).to be_a(Time)
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
			
			# Should have called ready! at least once
			expect(instance.ready.pop).to be_a(Time)
		end
	end
end

