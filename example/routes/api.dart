import 'package:daravel_core/http/daravel_router.dart';

import '../app/http/controllers/test_controller.dart';

final apiRouter = DaravelRouter();

void apiRoutes() {
  apiRouter.get('/v1', TestController().api);
  apiRouter.get('/v1/echo/<message>', TestController().echo);
}
