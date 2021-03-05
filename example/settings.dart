import 'package:dbus/dbus.dart';
import 'package:nm/nm.dart';

void main() async {
  var systemBus = DBusClient.system();
  var client = NetworkManagerClient(systemBus);
  await client.connect();
  for (var connection in client.settings.connections) {
    var settings = await connection.getSettings();
    var connectionSettings = settings['connection'];
    var connectionId = connectionSettings['id'].toNative();
    print('$connectionId');
  }
  await systemBus.close();
}
