import 'package:dbus/dbus.dart';
import 'package:networkmanager/networkmanager.dart';

void main() async {
  var systemBus = DBusClient.system();
  var client = NetworkManagerClient(systemBus);
  await client.connect();
  client.propertiesChangedStream.listen((propertyNames) {
    print(propertyNames);
    if (propertyNames.contains('NetworkingEnabled') ||
        propertyNames.contains('ConnectivityCheckEnabled') ||
        propertyNames.contains('Connectivity')) {
      checkConnectivity(client);
    }
  });
  checkConnectivity(client);
}

void checkConnectivity(NetworkManagerClient client) {
  if (!client.networkingEnabled) {
    print('Networking is disabled');
  } else if (client.connectivityCheckEnabled) {
    var connectivity = client.connectivity;
    print('Network connectivity state is ${connectivity}');
  } else {
    print("Can't determine connectivity");
  }
}
