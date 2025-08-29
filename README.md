# Mosaic DevTools

Interactive debugging and visualization tools for Mosaic modular Flutter applications.

## Features

- **Module Inspector** - Real-time module lifecycle and state monitoring
- **Event Monitor** - Live event stream with pattern matching visualization  
- **Dependency Viewer** - Interactive dependency injection container explorer
- **Navigation Stack** - Internal routing and stack management inspector

## Installation

```yaml
dev_dependencies:
  mosaic_devtools: ^1.0.0
```

## Quick Start

```dart
import 'package:mosaic_devtools/mosaic_devtools.dart';

void main() async {
  await logger.init(/*...*/);
  
  if (kDebugMode) {
    MosaicDevtools.init();
  }
  
  runApp(MyApp());
}
```

## Usage

**Overlay Mode:**
```dart
Widget build(BuildContext context) {
  return MosaicDevtools.wrap(
    child: MosaicScope(),
    position: DevtoolsPosition.bottomRight,
  );
}
```

## What You'll See

- Active modules and their current states
- Real-time event emissions with data payloads
- Dependency injection registrations and retrievals
- Module navigation stack changes
- Logger output with filtering by tags

Perfect for development, debugging, and understanding your Mosaic architecture.

---

**Note:** DevTools are automatically excluded from release builds and have zero production impact.
