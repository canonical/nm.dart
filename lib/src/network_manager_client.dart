import 'package:dbus/dbus.dart';

class NetworkManagerSettings {}

/// A client that connects to NetworkManager.
class NetworkManagerClient {
  /// The bus this client is connected to.
  final DBusClient systemBus;

  /// The root D-Bus NetworkManager object at path '/org/freedesktop'.
  DBusRemoteObject _root;

  // Objects exported on the bus.
  final _objects = <DBusObjectPath, DBusRemoteObject>{};

  /// Creates a new NetworkManager client connected to the system D-Bus.
  NetworkManagerClient(DBusClient this.systemBus);

  /// Gets the version of NetworkManager running.
  Future<String> get version async {
    var main = await _getMain();
    var value =
        await main.getProperty('org.freedesktop.NetworkManager', 'Version');
    return (value as DBusString).value;
  }

  /// Gets the hostname
  Future<String> get hostname async {
    var settings = await _getSettings();
    var value = await settings.getProperty(
        'org.freedesktop.NetworkManager.Settings', 'Hostname');
    return (value as DBusString).value;
  }

  /// Connects to the NetworkManager D-Bus objects.
  void _connect() async {
    // Already connected
    if (_root != null) {
      return;
    }

    // Find all the objects exported.
    _root = DBusRemoteObject(systemBus, 'org.freedesktop.NetworkManager',
        DBusObjectPath('/org/freedesktop'));
    var objects = await _root.getManagedObjects();
    objects.forEach((objectPath, interfaces) {
      _objects[objectPath] = DBusRemoteObject(
          systemBus, 'org.freedesktop.NetworkManager', objectPath);
    });
  }

  /// Gets a remote object.
  Future<DBusRemoteObject> _getObject(DBusObjectPath objectPath) async {
    await _connect();
    return _objects[objectPath];
  }

  /// Gets the main object.
  Future<DBusRemoteObject> _getMain() async =>
      _getObject(DBusObjectPath('/org/freedesktop/NetworkManager'));

  /// Gets the settings object.
  Future<DBusRemoteObject> _getSettings() async =>
      _getObject(DBusObjectPath('/org/freedesktop/NetworkManager/Settings'));
}
