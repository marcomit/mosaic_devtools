import 'package:flutter/material.dart';
import 'package:mosaic/mosaic.dart';
import 'package:mosaic_devtools/inspector_card.dart';
import 'modules_inspector_view.dart';

class ModulesInspectorModule extends Module {
  ModulesInspectorModule() : super(name: 'inspector_modules');

  @override
  Future<void> onInit() async {
    final card = InspectorCard(name: name);
    injector.inject('devtools/dashboard', ModularExtension(card.build));
  }

  @override
  Widget build(BuildContext context) {
    return const ModulesInspectorView();
  }
}
