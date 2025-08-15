# Releases

## Unreleased

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
