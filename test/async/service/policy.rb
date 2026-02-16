# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

require "async/service/policy"
require "async/container/statistics"

describe Async::Service::Policy do
	let(:policy) {subject.new(maximum_failures: 5, window: 10)}
	
	with "::DEFAULT" do
		it "exists and is frozen" do
			expect(Async::Service::Policy::DEFAULT).not.to be_nil
			expect(Async::Service::Policy::DEFAULT).to be(:frozen?)
		end
		
		it "is a Service::Policy instance" do
			expect(Async::Service::Policy::DEFAULT).to be_a(Async::Service::Policy)
		end
	end
	
	with "failure rate monitoring" do
		let(:mock_container) do
			Class.new do
				attr_reader :stopped, :statistics
				
				def initialize
					@stopped = false
					@statistics = Async::Container::Statistics.new(window: 10)
				end
				
				def running?
					!@stopped
				end
				
				def stop(graceful)
					@stopped = true
				end
			end.new
		end
		
		let(:mock_status) do
			Class.new do
				def success?
					false
				end
			end.new
		end
		
		it "stops container when failure rate exceeds threshold" do
			# Policy with max 5 failures in 10 second window
			policy = subject.new(maximum_failures: 5, window: 10)
			
			# Add 6 failures (exceeds threshold of 5 in 10 seconds)
			6.times do
				mock_container.statistics.failure!
			end
			
			# 6 failures in same second = 0.6/sec which exceeds 5/10sec = 0.5/sec
			rate = mock_container.statistics.failure_rate.per_second
			expect(rate).to be > 0.5
			expect(mock_container.stopped).to be == false
			
			# Trigger policy check
			policy.child_exit(mock_container, nil, mock_status, name: "test", key: nil)
			
			expect(mock_container.stopped).to be == true
		end
		
		it "does not stop container when failure rate is acceptable" do
			# Policy with max 10 failures in 10 second window  
			policy = subject.new(maximum_failures: 10, window: 10)
			
			# Add only 3 failures (below threshold)
			3.times do
				mock_container.statistics.failure!
			end
			
			# 3 failures = 0.3/sec which is below 10/10sec = 1.0/sec
			rate = mock_container.statistics.failure_rate.per_second
			expect(rate).to be < 1.0
			
			# Trigger policy check
			policy.child_exit(mock_container, nil, mock_status, name: "test", key: nil)
			
			expect(mock_container.stopped).to be == false
		end
		
		it "does nothing on successful exit" do
			policy = subject.new(maximum_failures: 1, window: 10)
			
			success_status = Object.new
			def success_status.success?; true; end
			
			# Even with low threshold, success shouldn't trigger stop
			policy.child_exit(mock_container, nil, success_status, name: "test", key: nil)
			
			expect(mock_container.stopped).to be == false
		end
		
		it "does not stop container if already stopping" do
			policy = subject.new(maximum_failures: 1, window: 10)
			
			# Add failures to exceed threshold
			2.times do
				mock_container.statistics.failure!
			end
			
			# Manually stop the container first
			mock_container.stop(true)
			expect(mock_container.stopped).to be == true
			expect(mock_container.running?).to be == false
			
			# Policy should not call stop again
			policy.child_exit(mock_container, nil, mock_status, name: "test", key: nil)
			
			# Container is still stopped (no error from redundant stop call)
			expect(mock_container.stopped).to be == true
		end
	end
	
	with "initialization" do
		it "computes threshold from maximum_failures and window" do
			policy = subject.new(maximum_failures: 10, window: 60)
			
			# 10 failures / 60 seconds = 0.167 failures/sec
			expect(policy.failure_rate_threshold).to be_within(0.001).of(0.167)
		end
		
		it "handles different window sizes" do
			policy = subject.new(maximum_failures: 5, window: 10)
			
			# 5 failures / 10 seconds = 0.5 failures/sec
			expect(policy.failure_rate_threshold).to be == 0.5
		end
		
		it "uses default parameters" do
			policy = subject.new
			
			# Default: 6 failures / 60 seconds = 0.1 failures/sec
			expect(policy.failure_rate_threshold).to be == 0.1
		end
	end
	
	with "#make_statistics" do
		it "creates statistics with matching window" do
			policy = subject.new(maximum_failures: 5, window: 30)
			statistics = policy.make_statistics
			
			expect(statistics.failure_rate.window).to be == 30
		end
		
		it "DEFAULT uses 60 second window" do
			statistics = Async::Service::Policy::DEFAULT.make_statistics
			
			expect(statistics.failure_rate.window).to be == 60
		end
	end
end
