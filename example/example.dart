import 'package:dbus/dbus.dart';
import 'package:network_manager/network_manager.dart';

void main() async {
  var systemBus = DBusClient.system();
  var client = NetworkManagerClient(systemBus);
  var xml = await client.introspect();
  print('${xml}');
  await systemBus.close();
}
