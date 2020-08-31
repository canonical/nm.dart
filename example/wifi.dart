import 'dart:convert';

import 'package:dbus/dbus.dart';
import 'package:networkmanager/networkmanager.dart';

void main() async {
  var systemBus = DBusClient.system();
  var client = NetworkManagerClient(systemBus);
  await client.connect();
  for (var device in client.devices) {
    if (device.deviceType == DeviceType.wifi) {
      print('${device.hwAddress}');
      for (var accessPoint in device.wireless.accessPoints) {
        var strength = accessPoint.strength.toString().padRight(3);
        print("  ${strength} '${utf8.decode(accessPoint.ssid)}'");
      }
    }
  }
  await systemBus.close();
}
