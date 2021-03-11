import 'package:nm/nm.dart';

void main() async {
  var client = NetworkManagerClient();
  await client.connect();
  for (var connection in client.settings.connections) {
    var settings = await connection.getSettings();
    var connectionSettings = settings['connection'];
    var connectionId = connectionSettings?['id']?.toNative();
    print('$connectionId');
  }
  await client.close();
}
