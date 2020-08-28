import 'package:dbus/dbus.dart';
import 'package:network_manager/network_manager.dart';

void main() async {
  var systemBus = DBusClient.system();
  var client = NetworkManagerClient(systemBus);
  await client.connect();
  if (!client.networkingEnabled) {
    print('Networking is disabled');
  } else if (client.connectivityCheckEnabled) {
    var connectivity = client.connectivity;
    print('Network connectivity state is ${connectivity}');
  } else {
    print("Can't determine connectivity");
  }
  await systemBus.close();
}
