[![Pub Package](https://img.shields.io/pub/v/networkmanager.svg)](https://pub.dev/packages/networkmanager)

Provides a client to connect to [NetworkManager](https://gitlab.freedesktop.org/NetworkManager/NetworkManager) - the service that manages network connections on Linux.

```dart
import 'package:dbus/dbus.dart';
import 'package:networkmanager/networkmanager.dart';

var systemBus = DBusClient.system();
var client = NetworkManagerClient(systemBus);
await client.connect();
print('Running NetworkManager ${client.version}');
await systemBus.close();
```
