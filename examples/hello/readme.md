# Hello Service Example

This example demonstrates the most basic usage of Async::Service - creating a simple service that prints "Hello World!" every second.

## Running the Example

Make the file executable and run it:

~~~ bash
$ chmod +x hello.rb
$ ./hello.rb
~~~

You should see output like this:

```
Hello World!
Hello World!
Hello World!
...
```

Press `Ctrl+C` to stop the service.

## How it Works

The example defines a simple service class:

~~~ ruby
class SleepService < Async::Service::GenericService
	def setup(container)
		super
		
		container.run(count: 1, restart: true) do |instance|
			instance.ready!
			
			while true
				puts "Hello World!"
				sleep 1
			end
		end
	end
end
~~~

Key points:

- **Inherits from `Async::Service::GenericService`**: Provides the basic service interface
- **Implements `setup(container)`**: Defines how the service runs
- **Uses `container.run`**: Creates one instance with automatic restart
- **Calls `instance.ready!`**: Signals the service is ready
- **Contains the main loop**: The actual service logic

The service is then configured and made available for execution:

~~~ ruby
service "sleep" do
	service_class SleepService
end
~~~

## What's Next?

Try modifying the example:

- Change the message that gets printed
- Adjust the sleep interval
- Add multiple instances by changing `count: 1` to `count: 3`
- Add environment variables or configuration

For more complex examples, check out the [Getting Started Guide](../../guides/getting-started/).
