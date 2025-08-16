# IPC Example

This example demonstrates Inter-Process Communication (IPC) using Unix domain sockets with two async services:

- **IPC Server**: Listens on a Unix domain socket and responds with "Hello World" to each connection
- **IPC Client**: Periodically connects to the server and prints the received message

Both services use `ContainerService` as the base class, which provides built-in health checking, process title formatting, and container management.

## Configuration

The example uses a shared environment module (`IPCEnvironment`) that includes `ContainerEnvironment` for container configuration:

```ruby
module IPCEnvironment
	include Async::Service::ContainerEnvironment
	
	def ipc_socket_path
		File.expand_path("service.ipc", Dir.pwd)
	end
	
	def ipc_connection_timeout
		5.0
	end
	
	def count
		1  # Run single instance of each service
	end
end
```

### Customizing the Socket Path

You can override the socket path by modifying the `IPCEnvironment` module:

```ruby
module IPCEnvironment
	def ipc_socket_path
		"/tmp/my_custom_ipc.sock"
	end
end
```

## Usage

```bash
# Run both services together:
bundle exec service.rb
```

## Expected Output

The server will start first and begin listening:

```
IPC Server listening on /Users/your-username/your-project/service.ipc
```

The client will then periodically connect:

```
Connected to server
Received from server: Hello World
Connection closed
```

This process repeats every 5 seconds (2 second delay + 3 second wait), demonstrating persistent IPC communication between services.
