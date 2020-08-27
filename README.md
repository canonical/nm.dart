[![Pub Package](https://img.shields.io/pub/v/network_manager.svg)](https://pub.dev/packages/network_manager)

Provides a client to connect to [NetworkManager](https://gitlab.freedesktop.org/NetworkManager/NetworkManager) - the service that manages network connections on Linux.

```dart
import 'package:dbus/dbus.dart';
import 'package:network_manager/network_manager.dart';

var systemBus = DBusClient.system();
var client = NetworkManagerClient(systemBus);
var version = await client.version;
print('Running NetworkManager ${version}');
await systemBus.close();
```
