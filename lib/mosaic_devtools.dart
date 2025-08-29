import 'package:mosaic/mosaic.dart';
import 'package:mosaic_devtools/tesserae/devtools.dart';
import 'package:mosaic_devtools/tesserae/events/events.dart';
import 'package:mosaic_devtools/tesserae/logger/logger.dart';
import 'package:mosaic_devtools/tesserae/module/module.dart';
import 'package:mosaic_devtools/tesserae/router/router.dart';

class MosaicDevtools {
  static Future<void> initialize() async {
    final devtools = DevToolsModule();
    await moduleManager.register(devtools);

    final eventModule = EventModule();
    eventModule.dependencies.add(devtools);
    await moduleManager.register(EventModule());

    final loggerModule = LoggerInspectorModule();
    loggerModule.dependencies.add(devtools);
    await moduleManager.register(loggerModule);

    final module = ModulesInspectorModule();
    module.dependencies.add(devtools);
    await moduleManager.register(module);

    final routerModule = RouterInspectorModule();
    routerModule.dependencies.add(devtools);
    await moduleManager.register(routerModule);
  }
}
