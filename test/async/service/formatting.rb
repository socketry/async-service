# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025, by Samuel Williams.

require "async/service/formatting"

describe Async::Service::Formatting do
	with "#format_count" do
		it "formats small numbers without units" do
			expect(subject.format_count(0)).to be == "0"
			expect(subject.format_count(0.0)).to be == "0.0"
			
			expect(subject.format_count(1)).to be == "1"
			expect(subject.format_count(1.0)).to be == "1.0"
			
			expect(subject.format_count(999)).to be == "999"
		end
		
		it "formats thousands with K unit" do
			expect(subject.format_count(1000)).to be == "1.0K"
			expect(subject.format_count(1500)).to be == "1.5K"
			expect(subject.format_count(999999)).to be == "1000.0K"
		end
		
		it "formats millions with M unit" do
			expect(subject.format_count(1000000)).to be == "1.0M"
			expect(subject.format_count(1500000)).to be == "1.5M"
			expect(subject.format_count(2340000)).to be == "2.34M"
		end
		
		it "formats billions with B unit" do
			expect(subject.format_count(1000000000)).to be == "1.0B"
			expect(subject.format_count(1500000000)).to be == "1.5B"
		end
		
		it "formats trillions with T unit" do
			expect(subject.format_count(1000000000000)).to be == "1.0T"
			expect(subject.format_count(1500000000000)).to be == "1.5T"
		end
		
		it "handles very large numbers" do
			expect(subject.format_count(1000000000000000)).to be == "1.0P"
			expect(subject.format_count(1000000000000000000)).to be == "1.0E"
		end
		
		it "rounds to 2 decimal places" do
			expect(subject.format_count(1234)).to be == "1.23K"
			expect(subject.format_count(1235)).to be == "1.24K" # Rounds up
			expect(subject.format_count(1999)).to be == "2.0K"
		end
		
		it "handles decimal inputs" do
			expect(subject.format_count(1500.5)).to be == "1.5K"
			expect(subject.format_count(1234.567)).to be == "1.23K"
		end
		
		it "handles negative numbers" do
			expect(subject.format_count(-1000)).to be == "-1.0K"
			expect(subject.format_count(-1234567)).to be == "-1.23M"
		end
		
		with "custom units" do
			it "uses custom unit arrays" do
				custom_units = [nil, "k", "m"]
				expect(subject.format_count(1000, custom_units)).to be == "1.0k"
				expect(subject.format_count(1000000, custom_units)).to be == "1.0m"
			end
			
			it "stops at the last unit for very large numbers" do
				custom_units = [nil, "K"]
				expect(subject.format_count(1000000, custom_units)).to be == "1000.0K"
			end
			
			it "handles empty units array" do
				expect(subject.format_count(1000, [])).to be == "1000.0"
			end
			
			it "handles single nil unit" do
				expect(subject.format_count(1000, [nil])).to be == "1000.0"
			end
		end
	end
	
	with "#format_ratio" do
		it "formats ratios with appropriate units" do
			expect(subject.format_ratio(23, 3420)).to be == "23.0/3.42K"
			expect(subject.format_ratio(2, 3420)).to be == "2.0/3.42K"
		end
		
		it "handles large ratios" do
			expect(subject.format_ratio(1500000, 2340000000)).to be == "1.5M/2.34B"
		end
		
		it "handles small ratios" do
			expect(subject.format_ratio(5, 100)).to be == "5.0/100.0"
		end
		
		it "handles zero values" do
			expect(subject.format_ratio(0, 1000)).to be == "0.0/1.0K"
			expect(subject.format_ratio(100, 0)).to be == "100.0/0.0"
		end
	end
	
	with "#format_load" do
		it "formats load to 2 decimal places" do
			expect(subject.format_load(0.273)).to be == "0.27"
			expect(subject.format_load(1.0)).to be == "1.0"
			expect(subject.format_load(0.0)).to be == "0.0"
		end
		
		it "handles load values greater than 1" do
			expect(subject.format_load(2.5)).to be == "2.5"
			expect(subject.format_load(10.123456)).to be == "10.12"
		end
	end
	
	with "#format_statistics" do
		it "formats single values" do
			result = subject.format_statistics(connections: 23)
			expect(result).to be == "CONNECTIONS=23.0"
		end
		
		it "formats ratios from arrays" do
			result = subject.format_statistics(c: [23, 3420])
			expect(result).to be == "C=23.0/3.42K"
		end
		
		it "formats multiple statistics" do
			result = subject.format_statistics(
				c: [23, 3420], 
				r: [2, 3420]
			)
			expect(result).to be == "C=23.0/3.42K R=2.0/3.42K"
		end
		
		it "handles mixed statistic types" do
			result = subject.format_statistics(
				connections: [23, 3420],
				active: 5,
				load: 0.273
			)
			expect(result).to be == "CONNECTIONS=23.0/3.42K ACTIVE=5.0 LOAD=0.27"
		end
		
		it "handles arrays with more than 2 elements" do
			result = subject.format_statistics(multi: [1, 2, 3])
			expect(result).to be == "MULTI=1/2/3"
		end
		
		it "handles empty statistics" do
			result = subject.format_statistics()
			expect(result).to be == ""
		end
		
		it "handles symbol and string keys" do
			result = subject.format_statistics(
				:symbol_key => 100,
				"string_key" => 200
			)
			expect(result).to be == "SYMBOL_KEY=100.0 STRING_KEY=200.0"
		end
	end
	
	with "real-world examples" do
		it "formats Falcon-style statistics" do
			# Simulating the Falcon use case
			connection_count = 23
			accept_count = 3420
			active_count = 2
			request_count = 3420
			
			statistics = subject.format_statistics(
				c: [connection_count, accept_count],
				r: [active_count, request_count]
			)
			
			expect(statistics).to be == "C=23.0/3.42K R=2.0/3.42K"
		end
		
		it "formats process title information" do
			load_value = 0.273456
			
			formatted_load = subject.format_load(load_value)
			expect(formatted_load).to be == "0.27"
			
			# Simulating full process title
			service_name = "web-server"
			stats = subject.format_statistics(
				c: [23, 3420],
				r: [2, 3420]
			)
			
			process_title = "#{service_name} (#{stats} L=#{formatted_load})"
			expect(process_title).to be == "web-server (C=23.0/3.42K R=2.0/3.42K L=0.27)"
		end
	end
end
