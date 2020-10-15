[![Pub Package](https://img.shields.io/pub/v/nm.svg)](https://pub.dev/packages/nm)

Provides a client to connect to [NetworkManager](https://gitlab.freedesktop.org/NetworkManager/NetworkManager) - the service that manages network connections on Linux.

```dart
import 'package:dbus/dbus.dart';
import 'package:nm/nm.dart';

var systemBus = DBusClient.system();
var client = NetworkManagerClient(systemBus);
await client.connect();
print('Running NetworkManager ${client.version}');
await systemBus.close();
```

## Contributing to nm.dart

We welcome contributions! See the [contribution guide](CONTRIBUTING.md) for more details.
