import 'dart:convert';
import 'dart:io';

import 'package:dbus/dbus.dart';
import 'package:nm/nm.dart';

void main() async {
  var client = NetworkManagerClient();
  await client.connect();

  NetworkManagerDevice device;
  try {
    device = client.devices
        .firstWhere((d) => d.deviceType == NetworkManagerDeviceType.wifi);
  } catch (e) {
    print('No WiFi devices found');
    return;
  }

  var wireless = device.wireless!;

  print('Scanning WiFi device ${device.hwAddress}...');
  await wireless.requestScan();

  wireless.propertiesChanged.listen((propertyNames) {
    if (propertyNames.contains('LastScan')) {
      /// Get APs with names.
      var accessPoints =
          wireless.accessPoints.where((a) => a.ssid.isNotEmpty).toList();

      // Sort by signal strength.
      accessPoints.sort((a, b) => b.strength.compareTo(a.strength));

      for (var accessPoint in accessPoints) {
        var ssid = utf8.decode(accessPoint.ssid);
        var strength = accessPoint.strength.toString().padRight(3);
        print("  ${accessPoint.frequency}MHz $strength '$ssid'");
      }
      if (accessPoints.isNotEmpty) {
        connectToWifiNetwork(client, device, accessPoints.first);
      }
      exit(0);
    }
  });
}

void connectToWifiNetwork(NetworkManagerClient manager,
    NetworkManagerDevice device, NetworkManagerAccessPoint accessPoint) async {
  try {
    // Has password
    if (accessPoint.rsnFlags.isNotEmpty) {
      var password = stdin.readLineSync(encoding: utf8);
      if (password != null) {
        await manager.addAndActivateConnection(
            device: device,
            accessPoint: accessPoint,
            connection: {
              "802-11-wireless-security": {
                "key-mgmt": DBusString('wpa-psk'),
                "psk": DBusString(password)
              }
            });
      }
    } else {
      await manager.addAndActivateConnection(
          device: device, accessPoint: accessPoint);
    }
  } catch (e) {
    print(e);
  }
}
