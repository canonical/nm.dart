import 'package:nm/nm.dart';

void main() async {
  var client = NetworkManagerClient();
  await client.connect();
  print('Networking state is ${client.state}');
  client.propertiesChanged.listen((propertyNames) {
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
    print('Network connectivity state is $connectivity');
  } else {
    print("Can't determine connectivity");
  }
}
