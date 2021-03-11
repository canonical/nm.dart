import 'package:nm/nm.dart';

void main() async {
  var client = NetworkManagerClient();
  await client.connect();
  print('Running NetworkManager ${client.version}');
  await client.close();
}
