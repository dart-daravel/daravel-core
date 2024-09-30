import 'package:daravel_core/http/daravel_router.dart';

import '../app/http/controllers/test_controller.dart';

final webRouter = DaravelRouter();

void apiRoutes() {
  webRouter.get('/', TestController().web);
}
