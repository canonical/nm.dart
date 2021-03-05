import 'dart:convert';
import 'dart:io';

import 'package:dbus/dbus.dart';
import 'package:nm/nm.dart';

void main() async {
  var systemBus = DBusClient.system();
  var client = NetworkManagerClient(systemBus);
  await client.connect();

  var device = client.devices
      .firstWhere((d) => d.deviceType == NetworkManagerDeviceType.wifi);
  if (device == null) {
    print('No WiFi devices found');
    return;
  }

  print('Scanning WiFi device ${device.hwAddress}...');
  await device.wireless.requestScan();

  device.wireless.propertiesChangedStream.listen((propertyNames) {
    if (propertyNames.contains('LastScan')) {
      /// Get APs with names.
      var accessPoints =
          device.wireless.accessPoints.where((a) => a.ssid.isNotEmpty).toList();

      // Sort by signal strength.
      accessPoints.sort((a, b) => b.strength.compareTo(a.strength));

      for (var accessPoint in accessPoints) {
        var ssid = utf8.decode(accessPoint.ssid);
        var strength = accessPoint.strength.toString().padRight(3);
        print("  ${accessPoint.frequency}MHz $strength '$ssid'");
      }

      exit(0);
    }
  });
}
