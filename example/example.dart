import 'package:dbus/dbus.dart';
import 'package:network_manager/network_manager.dart';

void main() async {
  var systemBus = DBusClient.system();
  var client = NetworkManagerClient(systemBus);
  var version = await client.version;
  print('Running NetworkManager ${version}');
  await systemBus.close();
}
