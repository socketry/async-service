# Releases

## v0.18.1

  - Remove prepared and running log messages - not as useful as I imagined, and quite noisy.

## v0.18.0

  - Start health checker earlier in the process. Use `#healthy!` message instead of `#ready!`.
  - Emit prepared and running log messages with durations (e.g. how long it took to transition to prepared and running states).
  - `Async::Service::Configuration.build{|loader|...}` can now take an argument for more flexible configuration construction.

## v0.17.0

  - `ManagedService` now sends `status!` messages during startup to prevent premature health check timeouts for slow-starting services.
  - Support for `startup_timeout` option via `container_options` to detect processes that hang during startup and never become ready.

## v0.16.0

  - Renamed `Async::Service::Generic` -\> `Async::Service::GenericService`, added compatibilty alias.
  - Renamed `Async::Service::Managed::Service` -\> `Async::Service::ManagedService`.
  - Renamed `Async::Service::Managed::Environment` -\> `Async::Service::ManagedEnvironment`.

## v0.15.1

  - `Managed::Service` should run within `Async do ... end`.

## v0.15.0

  - Rename `ContainerEnvironment` and `ContainerService` to `Managed::Environment` and `Managed::Service` respectively.
  - Health check uses `Fiber.new{instance.ready!}.resume` to confirm fiber allocation is working.

## v0.14.4

  - Use `String::Format` gem for formatting.

## v0.14.0

  - Introduce `ContainerEnvironment` and `ContainerService` for implementing best-practice services.

## v0.13.0

  - Fix null services handling.
  - Modernize code and improve documentation.
  - Make service name optional and improve code comments.
  - Add `respond_to_missing?` for completeness.

## v0.12.0

  - Add convenient `Configuration.build{...}` method for constructing inline configurations.

## v0.11.0

  - Allow builder with argument for more flexible configuration construction.

## v0.10.0

  - Add `Environment::Evaluator#as_json` for JSON serialization support.
  - Allow constructing a configuration with existing environments.

## v0.9.0

  - Allow providing a list of modules to include in environments.

## v0.8.0

  - Introduce `Environment#implements?` and related methods for interface checking.

## v0.7.0

  - Allow instance methods that take arguments in environments.

## v0.6.1

  - Fix requirement that facet must be a module.

## v0.6.0

  - Unify construction of environments for better consistency.

## v0.5.1

  - Relax dependency on async-container for better compatibility.

## v0.5.0

  - Add support for passing through options to controllers.

## v0.4.0

  - Reuse evaluator for service instances for better performance.
  - Expose `Configuration.load` and `Controller.start` for better composition.
  - Add simple service example.

## v0.3.1

  - Fix usage of `raise` in `BasicObject` context.

## v0.3.0

  - Use modules for environments instead of basic objects.
  - Allow non-modules to be included in environments.

## v0.2.1

  - Add missing call to `super` in service implementations.

## v0.2.0

  - Add support for loading other configuration files.
  - Minor bug fixes and improvements.

## v0.1.0

  - Initial release with core service framework.
  - Environment abstraction for service configuration.
  - Improved evaluator implementation with comprehensive tests.
  - Controller for handling service execution.
  - Support for explicit `service_class` configuration.
