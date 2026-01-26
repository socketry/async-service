# Async::Service

Provides a simple service interface for configuring and running asynchronous services in Ruby.

[![Development Status](https://github.com/socketry/async-service/workflows/Test/badge.svg)](https://github.com/socketry/async-service/actions?workflow=Test)

## Features

  - **Service Management**: Define, configure, and run long-running services.
  - **Container Integration**: Built on `async-container` for robust process management.
  - **Multiple Services**: Run and coordinate multiple services together.
  - **Automatic Restart**: Services automatically restart on failure.
  - **Graceful Shutdown**: Clean shutdown handling with proper resource cleanup.
  - **Environment Configuration**: Configure services with environment variables and settings.

## Usage

Please see the [project documentation](https://socketry.github.io/async-service/) for more details.

  - [Getting Started](https://socketry.github.io/async-service/guides/getting-started/index) - This guide explains how to get started with `async-service` to create and run services in Ruby.

  - [Service Architecture](https://socketry.github.io/async-service/guides/service-architecture/index) - This guide explains the key architectural components of `async-service` and how they work together to provide a clean separation of concerns.

  - [Best Practices](https://socketry.github.io/async-service/guides/best-practices/index) - This guide outlines recommended patterns and practices for building robust, maintainable services with `async-service`.

  - [Deployment](https://socketry.github.io/async-service/guides/deployment/index) - This guide explains how to deploy `async-service` applications using systemd and Kubernetes. We'll use a simple example service to demonstrate deployment configurations.

## Releases

Please see the [project releases](https://socketry.github.io/async-service/releases/index) for all releases.

### v0.18.0

  - Start health checker earlier in the process. Use `#healthy!` message instead of `#ready!`.
  - Emit prepared and running log messages with durations (e.g. how long it took to transition to prepared and running states).
  - `Async::Service::Configuration.build{|loader|...}` can now take an argument for more flexible configuration construction.

### v0.17.0

  - `ManagedService` now sends `status!` messages during startup to prevent premature health check timeouts for slow-starting services.
  - Support for `startup_timeout` option via `container_options` to detect processes that hang during startup and never become ready.

### v0.16.0

  - Renamed `Async::Service::Generic` -\> `Async::Service::GenericService`, added compatibilty alias.
  - Renamed `Async::Service::Managed::Service` -\> `Async::Service::ManagedService`.
  - Renamed `Async::Service::Managed::Environment` -\> `Async::Service::ManagedEnvironment`.

### v0.15.1

  - `Managed::Service` should run within `Async do ... end`.

### v0.15.0

  - Rename `ContainerEnvironment` and `ContainerService` to `Managed::Environment` and `Managed::Service` respectively.
  - Health check uses `Fiber.new{instance.ready!}.resume` to confirm fiber allocation is working.

### v0.14.4

  - Use `String::Format` gem for formatting.

### v0.14.0

  - Introduce `ContainerEnvironment` and `ContainerService` for implementing best-practice services.

### v0.13.0

  - Fix null services handling.
  - Modernize code and improve documentation.
  - Make service name optional and improve code comments.
  - Add `respond_to_missing?` for completeness.

### v0.12.0

  - Add convenient `Configuration.build{...}` method for constructing inline configurations.

### v0.11.0

  - Allow builder with argument for more flexible configuration construction.

## Contributing

We welcome contributions to this project.

1.  Fork it.
2.  Create your feature branch (`git checkout -b my-new-feature`).
3.  Commit your changes (`git commit -am 'Add some feature'`).
4.  Push to the branch (`git push origin my-new-feature`).
5.  Create new Pull Request.

### Developer Certificate of Origin

In order to protect users of this project, we require all contributors to comply with the [Developer Certificate of Origin](https://developercertificate.org/). This ensures that all contributions are properly licensed and attributed.

### Community Guidelines

This project is best served by a collaborative and respectful environment. Treat each other professionally, respect differing viewpoints, and engage constructively. Harassment, discrimination, or harmful behavior is not tolerated. Communicate clearly, listen actively, and support one another. If any issues arise, please inform the project maintainers.
