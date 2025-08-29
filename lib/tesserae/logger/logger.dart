import 'package:flutter/material.dart';
import 'package:mosaic/mosaic.dart';
import 'package:mosaic_devtools/inspector_card.dart';
import 'logger_inspector_view.dart';

final module = LoggerInspectorModule();

class LoggerInspectorModule extends Module {
  LoggerInspectorModule() : super(name: 'inspector_logger');

  @override
  Future<void> onInit() async {
    final card = InspectorCard(name: name);
    injector.inject('devtools/dashboard', ModularExtension(card.build));
  }

  @override
  Widget build(BuildContext context) {
    return const LoggerInspectorView();
  }
}
