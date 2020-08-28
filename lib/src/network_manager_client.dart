import 'package:dbus/dbus.dart';

class _NetworkManagerObject extends DBusRemoteObject {
  final Map<String, Map<String, DBusValue>> interfacesAndProperties;

  /// Gets a cached property.
  DBusValue getCachedProperty(String interface, String name) {
    var properties = interfacesAndProperties[interface];
    if (properties == null) {
      return null;
    }
    return properties[name];
  }

  /// Gets a cached boolean property, or returns null if not present or not the correct type.
  bool getBoolProperty(String interface, String name) {
    var value = getCachedProperty(interface, name);
    if (value == null) {
      return null;
    }
    if (value.signature != DBusSignature('b')) {
      return null;
    }
    return (value as DBusBoolean).value;
  }

  /// Gets a cached string property, or returns null if not present or not the correct type.
  String getStringProperty(String interface, String name) {
    var value = getCachedProperty(interface, name);
    if (value == null) {
      return null;
    }
    if (value.signature != DBusSignature('s')) {
      return null;
    }
    return (value as DBusString).value;
  }

  _NetworkManagerObject(
      DBusClient client, DBusObjectPath path, this.interfacesAndProperties)
      : super(client, 'org.freedesktop.NetworkManager', path) {}
}

class NetworkManagerSettings extends _NetworkManagerObject {
  NetworkManagerSettings(DBusClient client, DBusObjectPath path,
      Map<String, Map<String, DBusValue>> interfacesAndProperties)
      : super(client, path, interfacesAndProperties) {}
}

class NetworkManagerDevice extends _NetworkManagerObject {
  NetworkManagerDevice(DBusClient client, DBusObjectPath path,
      Map<String, Map<String, DBusValue>> interfacesAndProperties)
      : super(client, path, interfacesAndProperties) {}
}

/// A client that connects to NetworkManager.
class NetworkManagerClient {
  /// The bus this client is connected to.
  final DBusClient systemBus;

  /// The root D-Bus NetworkManager object at path '/org/freedesktop'.
  DBusRemoteObject _root;

  // Objects exported on the bus.
  final _objects = <DBusObjectPath, _NetworkManagerObject>{};

  /// Creates a new NetworkManager client connected to the system D-Bus.
  NetworkManagerClient(DBusClient this.systemBus);

  /// Connects to the NetworkManager D-Bus objects.
  /// Must be called before accessing methods and properties.
  void connect() async {
    // Already connected
    if (_root != null) {
      return;
    }

    // Find all the objects exported.
    _root = DBusRemoteObject(systemBus, 'org.freedesktop.NetworkManager',
        DBusObjectPath('/org/freedesktop'));
    var objects = await _root.getManagedObjects();
    objects.forEach((objectPath, interfacesAndProperties) {
      _objects[objectPath] =
          _NetworkManagerObject(systemBus, objectPath, interfacesAndProperties);
    });
  }

  /// Gets the version of NetworkManager running.
  String get version {
    if (_manager == null) {
      return null;
    }
    return _manager.getStringProperty(
        'org.freedesktop.NetworkManager', 'Version');
  }

  /// Gets the hostname
  String get hostname {
    if (_settings == null) {
      return null;
    }
    return _settings.getStringProperty(
        'org.freedesktop.NetworkManager.Settings', 'Hostname');
  }

  /// Gets the manager object.
  _NetworkManagerObject get _manager =>
      _objects[DBusObjectPath('/org/freedesktop/NetworkManager')];

  /// Gets the settings object.
  _NetworkManagerObject get _settings =>
      _objects[DBusObjectPath('/org/freedesktop/NetworkManager/Settings')];
}
