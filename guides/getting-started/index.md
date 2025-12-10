# Getting Started

Async::Service provides a simple service interface for configuring and running asynchronous services in Ruby. This guide will walk you through the basics of creating and running services.

## Installation

Add the gem to your project:

~~~ bash
$ bundle add async-service
~~~

Or add it to your `Gemfile`:

~~~ ruby
gem 'async-service'
~~~

## What is Async::Service?

Async::Service is a framework for building long-running services that can be managed as a group. It provides:

- **Service Configuration**: Define services with their dependencies and configuration
- **Service Controller**: Start, stop, and manage multiple services together
- **Container Integration**: Built on top of `async-container` for robust process management
- **Process Management**: Automatic restarts, graceful shutdowns, and process monitoring

## Your First Service

Let's create a simple service that prints "Hello World!" every second.

Create a file called `hello_service.rb`:

~~~ ruby
#!/usr/bin/env async-service
# frozen_string_literal: true

require 'async/service'

class HelloService < Async::Service::GenericService
	def setup(container)
		super
		
		# Run one instance of this service with automatic restart
		container.run(count: 1, restart: true) do |instance|
			# Signal that the service is ready
			instance.ready!
			
			# Main service loop
			while true
				puts "Hello World!"
				sleep 1
			end
		end
	end
end

# Define the service configuration
service "hello" do
	service_class HelloService
end
~~~

Make the file executable:

~~~ bash
$ chmod +x hello_service.rb
~~~

Run your service:

~~~ bash
$ ./hello_service.rb
~~~

You should see "Hello World!" printed every second. Press `Ctrl+C` to stop the service.

## Understanding the Structure

Let's break down the example:

### Service Class

~~~ ruby
class HelloService < Async::Service::GenericService
	def setup(container)
		super
		
		container.run(count: 1, restart: true) do |instance|
			instance.ready!
			
			# Your service logic here
		end
	end
end
~~~

- **Inherit from `Async::Service::GenericService`**: This provides the basic service interface
- **Implement `setup(container)`**: This method configures how your service runs
- **Call `super`**: Always call the parent's setup method
- **Use `container.run`**: Define how many instances to run and restart behavior
- **Call `instance.ready!`**: Signal that the service is ready to receive requests

### Service Configuration

~~~ ruby
service "hello" do
	service_class HelloService
end
~~~

- **`service` block**: Defines a named service configuration
- **`service_class`**: Specifies which class implements the service

## Configuration Options

Services can be configured with various options:

~~~ ruby
service "my-service" do
	service_class MyService
	
	# Set the service name (defaults to the block name)
	service_name "my-custom-service"
	
	# Add environment variables
	environment "PORT" => "3000"
	environment "LOG_LEVEL" => "debug"
	
	# Set the working directory
	root "/path/to/service"
	
	# Configure the service protocol
	protocol "http"
	endpoint "http://localhost:3000"
end
~~~

## Running Multiple Services

You can define multiple services in a single configuration file:

~~~ ruby
#!/usr/bin/env async-service
# frozen_string_literal: true

require 'async/service'

class WebService < Async::Service::GenericService
	def setup(container)
		super
		
		container.run(count: 1, restart: true) do |instance|
			instance.ready!
			
			# Start a web server here
			puts "Web service starting on port 3000"
			# Your web server code...
		end
	end
end

class WorkerService < Async::Service::GenericService
	def setup(container)
		super
		
		container.run(count: 2, restart: true) do |instance|
			instance.ready!
			
			# Start background workers
			puts "Worker #{instance.name} starting"
			# Your background job processing...
		end
	end
end

service "web" do
	service_class WebService
	environment "PORT" => "3000"
end

service "worker" do
	service_class WorkerService
	environment "WORKER_THREADS" => "2"
end
~~~

## Using the Command Line

The `async-service` command provides a convenient way to run service configurations:

~~~ bash
# Run a single service file
$ async-service my_service.rb

# Run multiple service files
$ async-service web_service.rb worker_service.rb

# The shebang line makes files directly executable
$ ./my_service.rb
~~~

## Loading from Ruby Code

You can also create and run services programmatically:

~~~ ruby
require 'async/service'

# Build configuration with a block
configuration = Async::Service::Configuration.build do
	service "my-service" do
		service_class MyService
	end
end

# Create and run controller
controller = configuration.controller
Async::Service::Controller.run(configuration)
~~~

## Error Handling and Logging

Services automatically handle errors and provide logging:

~~~ ruby
class RobustService < Async::Service::GenericService
	def setup(container)
		super
		
		container.run(count: 1, restart: true) do |instance|
			instance.ready!
			
			begin
				# Your service logic
				do_work()
			rescue => error
				# Log errors (they're automatically handled by the container)
				Console.error(self, error)
				raise # Re-raise to trigger restart if needed
			end
		end
	end
	
	private
	
	def do_work
		# Your actual service implementation
	end
end
~~~

## Next Steps

Now that you understand the basics, you can explore more advanced features:

- **Service Dependencies**: Configure services to depend on others
- **Health Checks**: Implement custom health checks for your services
- **Metrics and Monitoring**: Add observability to your services
- **Production Deployment**: Learn about deploying services in production

Check out the [examples](../../examples/) directory for more complex service implementations.

## Common Patterns

### HTTP Service

~~~ ruby
require 'async/http/server'
require 'async/http/endpoint'

class HTTPService < Async::Service::GenericService
	def setup(container)
		super
		
		container.run(count: 1, restart: true) do |instance|
			endpoint = Async::HTTP::Endpoint.parse("http://localhost:3000")
			
			server = Async::HTTP::Server.for(endpoint) do |request|
				Protocol::HTTP::Response[200, {}, ["Hello World!"]]
			end
			
			instance.ready!
			server.run
		end
	end
end
~~~

### Periodic Task Service

~~~ ruby
class PeriodicService < Async::Service::GenericService
	def setup(container)
		super
		
		container.run(count: 1, restart: true) do |instance|
			instance.ready!
			
			Async do |task|
				while true
					perform_periodic_task()
					task.sleep(60) # Wait 60 seconds
				end
			end
		end
	end
	
	private
	
	def perform_periodic_task
		puts "Performing periodic task at #{Time.now}"
		# Your periodic logic here
	end
end
~~~
