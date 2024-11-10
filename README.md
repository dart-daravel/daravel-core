[![test](https://github.com/Dart-Daravel/daravel-core/actions/workflows/test.yaml/badge.svg)](https://github.com/Dart-Daravel/daravel-core/actions/workflows/test.yaml) [![codecov](https://codecov.io/gh/Dart-Daravel/daravel-core/graph/badge.svg?token=ITU0NL7LY6)](https://codecov.io/gh/Dart-Daravel/daravel-core) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT) [![publish](https://github.com/Dart-Daravel/daravel-core/actions/workflows/publish.yaml/badge.svg)](https://github.com/Dart-Daravel/daravel-core/actions/workflows/publish.yaml) [![pub package](https://img.shields.io/pub/v/daravel_core.svg)](https://pub.dev/packages/daravel_core)

Daravel is a Laravel inspired back-end framework built in dart.

At the core of this framework is the `dart shelf` web server.

## Features

- Laravel like router.
- Middlewares.
- CORS.
- CLI Tool: `dartisan`.
- Database Support (SQlite at the moment).
- Query Builder.
- Schema Builder.
- More coming...

## Getting started

```bash
dart pub global activate daravel
```

## Usage

To create a new Daravel project, run the following:

```bash
dartisan new <project-name>
```

This will create a Daravel project with <project-name> and will contain a file structure similar to that of Laravel.

To generate important files for your project (this is run automatically after project creation), do the following:

```bash
dartisan generate
```

## Additional information

Contributions in any form, be it documentation, issues, pull requests, etc. are more than welcome.
For pull requests, please make sure that your commits are signed.
