import 'package:dbus/dbus.dart';
import 'package:nm/nm.dart';

void main() async {
  var systemBus = DBusClient.system();
  var client = NetworkManagerClient(systemBus);
  await client.connect();
  print('Running NetworkManager ${client.version}');
  await systemBus.close();
}
