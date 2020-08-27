import 'package:dbus/dbus.dart';

/// A client that connects to NetworkManager.
class NetworkManagerClient extends DBusRemoteObject {
  /// Creates a new NetworkManager client connected to the system D-Bus.
  NetworkManagerClient(DBusClient systemBus)
      : super(systemBus, 'org.freedesktop.NetworkManager',
            DBusObjectPath('/org/freedesktop'));
}
