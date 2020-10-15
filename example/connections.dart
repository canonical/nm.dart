import 'package:dbus/dbus.dart';
import 'package:nm/nm.dart';

void main() async {
  var systemBus = DBusClient.system();
  var client = NetworkManagerClient(systemBus);
  await client.connect();
  for (var connection in client.activeConnections) {
    var addresses = <String>[];

    var ip4Config = connection.ip4Config;
    if (ip4Config != null) {
      for (var data in ip4Config.addressData) {
        addresses.add(data['address']);
      }
    }

    var ip6Config = connection.ip6Config;
    if (ip6Config != null) {
      for (var data in ip6Config.addressData) {
        addresses.add(data['address']);
      }
    }

    print('${connection.id} ${addresses.join(' ')}');
  }
  await systemBus.close();
}
