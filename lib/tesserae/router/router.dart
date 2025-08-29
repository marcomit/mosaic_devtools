import 'package:flutter/material.dart';
import 'package:mosaic/mosaic.dart';
import 'package:mosaic_devtools/inspector_card.dart';
import 'router_inspector.dart';

final module = RouterInspectorModule();

class RouterInspectorModule extends Module {
  RouterInspectorModule() : super(name: 'inspector_router');

  @override
  Future<void> onInit() async {
    final card = InspectorCard(name: name);
    injector.inject('devtools/dashboard', ModularExtension(card.build));
  }

  @override
  Widget build(BuildContext context) {
    return const RouterInspectorView();
  }
}
