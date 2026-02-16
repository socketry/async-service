# Container Policies

This guide explains how to configure container policies for your services and understand the default failure handling behavior.

## Default Failure Handling

All services use {ruby Async::Service::Policy::DEFAULT} which monitors failure rates and stops the container when failures exceed a threshold.

**Default threshold:** 6 failures in 60 seconds (0.1 failures per second).

This means:
- Services can tolerate occasional failures and transient issues.
- More than 6 failures in any 60-second window stops the container.
- Prevents services from restart-looping indefinitely when fundamentally broken.

This fail-fast behavior is appropriate for orchestrated environments (Kubernetes, systemd) where the orchestrator will restart the entire service.

### Why This Default?

Without failure monitoring, a broken service with `restart: true` would restart indefinitely, wasting resources. The default policy:

- **Catches problems quickly**: Broken services stop within 10-20 seconds.
- **Prevents resource waste**: Doesn't keep trying to start services that will never succeed.
- **Enables orchestrator recovery**: Systemd/Kubernetes can restart the whole process with a clean state.
- **Detects environmental issues**: Bad hardware, corrupted pre-fork state, or system-level problems can't be fixed by restarting children - the entire service needs to be restarted (potentially on different hardware).
- **Signals clear failure**: Exit code indicates the service couldn't maintain healthy operation.

## Configuring Policies

Use `container_policy` in your service configuration to customize failure handling:

``` ruby
# config/service.rb

# More lenient: allow 5 failures per minute:
container_policy Async::Service::Policy.new(maximum_failures: 5, window: 60)

service "web" do
	# Your service configuration.
end

service "worker" do
	# Also uses the same policy.
end
```

The policy applies to **all services** in the configuration file.

### Choosing a Threshold

Consider your service characteristics:

**Strict (catch problems immediately):**
``` ruby
container_policy Async::Service::Policy.new(maximum_failures: 1, window: 5)
```

**Balanced (tolerate transient issues):**
``` ruby
container_policy Async::Service::Policy.new(maximum_failures: 5, window: 60)
```

**Lenient (allow many retries):**
``` ruby
container_policy Async::Service::Policy.new(maximum_failures: 20, window: 60)
```

Factors to consider:
- **Traffic volume**: High-traffic services may have more absolute failures.
- **Error types**: Some errors are transient (network timeouts, rate limits).
- **Dependencies**: Upstream services may need time to recover.
- **Deployment environment**: Kubernetes/systemd handle restarts, local dev doesn't.

## Per-Container Policy Instances

The `container_policy` method accepts a block that's evaluated **each time a container is created**:

``` ruby
# config/service.rb
container_policy do
	# This block is called for EACH container created
	# Each container gets its own policy instance with fresh state
	Async::Service::Policy.new(maximum_failures: 5, window: 60)
end
```

If your policy is tracking per-container state, this will ensure each container has new policy with clean state.
