
LogLevel = environment do
	log_level :info
end

service "test" do
	include LogLevel
	
	authority {self.name}
	middleware {Object.new}
end
