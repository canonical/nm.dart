import 'package:dbus/dbus.dart';
import 'package:network_manager/network_manager.dart';

void main() async {
  var systemBus = DBusClient.system();
  var client = NetworkManagerClient(systemBus);
  await client.connect();
  for (var device in client.devices) {
    print('${device.deviceType} ${device.hwAddress} ${device.state} ');
  }
  await systemBus.close();
}
