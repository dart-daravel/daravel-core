import 'package:args/command_runner.dart';

import 'package:daravel_core/daravel_core.dart';

import '../routes/api.dart';

import 'config.dart';

late final Core core;

void boot(List<String> args) async {
  bootConfig();
  apiRoutes();

  core = Core(
    configMap: config,
    routers: [
      apiRouter,
    ],
    globalMiddlewares: [
      LoggerMiddleware(),
    ],
  );

  CommandRunner("dartisan", "The CLI tool for Daravel")
    ..addCommand(ServeCommand(core))
    ..run(args);
}
