import 'package:nm/nm.dart';

void main() async {
  var client = NetworkManagerClient();
  await client.connect();
  for (var device in client.devices) {
    print(
        '${device.deviceType} ${device.hwAddress} ${device.state} ${device.generic.typeDescription}');
  }
  await client.close();
}
