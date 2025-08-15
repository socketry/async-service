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

## Releases

Please see the [project releases](https://socketry.github.io/async-service/releases/index) for all releases.

### Unreleased

### v0.13.0

  - Fix null services handling.
  - Modernize code and improve documentation.
  - Make service name optional and improve code comments.
  - Add `respond_to_missing?` for completeness.

### v0.12.0

  - Add convenient `Configuration.build{...}` method for constructing inline configurations.

### v0.11.0

  - Allow builder with argument for more flexible configuration construction.

### v0.10.0

  - Add `Environment::Evaluator#as_json` for JSON serialization support.
  - Allow constructing a configuration with existing environments.

### v0.9.0

  - Allow providing a list of modules to include in environments.

### v0.8.0

  - Introduce `Environment#implements?` and related methods for interface checking.

### v0.7.0

  - Allow instance methods that take arguments in environments.

### v0.6.1

  - Fix requirement that facet must be a module.

### v0.6.0

  - Unify construction of environments for better consistency.

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
