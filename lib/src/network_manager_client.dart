import 'package:dbus/dbus.dart';

enum ConnectivityState { unknown, none, portal, limited, full }

enum DeviceState {
  unknown,
  unmanaged,
  unavailable,
  disconnected,
  prepare,
  config,
  need_auth,
  ip_config,
  ip_check,
  secondaries,
  activated,
  deactivating,
  failed
}

enum DeviceType {
  unknown,
  ethernet,
  wifi,
  bluetooth,
  olpc_mesh,
  wimax,
  modem,
  infiniband,
  bond,
  vlan,
  adsl,
  bridge,
  generic,
  team,
  tun,
  ip_tunnel,
  macvlan,
  vxlan,
  veth,
  macsec,
  dummy,
  ppp,
  ovs_interface,
  ovs_port,
  ovs_bridge,
  wpan,
  _6lowpan,
  wireguard,
  wifi_p2p,
  vrf
}

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
  bool getBooleanProperty(String interface, String name) {
    var value = getCachedProperty(interface, name);
    if (value == null) {
      return null;
    }
    if (value.signature != DBusSignature('b')) {
      return null;
    }
    return (value as DBusBoolean).value;
  }

  /// Gets a cached unsigned 32 bit integer property, or returns null if not present or not the correct type.
  int getUint32Property(String interface, String name) {
    var value = getCachedProperty(interface, name);
    if (value == null) {
      return null;
    }
    if (value.signature != DBusSignature('u')) {
      return null;
    }
    return (value as DBusUint32).value;
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

  /// Gets a cached object path array property, or returns null if not present or not the correct type.
  List<DBusObjectPath> getObjectPathArrayProperty(
      String interface, String name) {
    var value = getCachedProperty(interface, name);
    if (value == null) {
      return null;
    }
    if (value.signature != DBusSignature('ao')) {
      return null;
    }
    return (value as DBusArray)
        .children
        .map((e) => (e as DBusObjectPath))
        .toList();
  }

  _NetworkManagerObject(
      DBusClient client, DBusObjectPath path, this.interfacesAndProperties)
      : super(client, 'org.freedesktop.NetworkManager', path) {}
}

class NetworkManagerDevice {
  final _NetworkManagerObject _object;

  NetworkManagerDevice(this._object) {}

  String get udi =>
      _object.getStringProperty('org.freedesktop.NetworkManager.Device', 'Udi');
  String get path => _object.getStringProperty(
      'org.freedesktop.NetworkManager.Device', 'Path');
  String get ipInterface => _object.getStringProperty(
      'org.freedesktop.NetworkManager.Device', 'IpInterface');
  String get driver => _object.getStringProperty(
      'org.freedesktop.NetworkManager.Device', 'Driver');
  String get driverVersion => _object.getStringProperty(
      'org.freedesktop.NetworkManager.Device', 'DriverVersion');
  String get firmwareVersion => _object.getStringProperty(
      'org.freedesktop.NetworkManager.Device', 'FirmwareVersion');
  int get capabilities => _object.getUint32Property(
      'org.freedesktop.NetworkManager.Device', 'Capabilities'); // FIXME: enum
  DeviceState get state {
    var value = _object.getUint32Property(
        'org.freedesktop.NetworkManager.Device', 'State');
    if (value == 10) {
      return DeviceState.unmanaged;
    } else if (value == 20) {
      return DeviceState.unavailable;
    } else if (value == 30) {
      return DeviceState.disconnected;
    } else if (value == 40) {
      return DeviceState.prepare;
    } else if (value == 50) {
      return DeviceState.config;
    } else if (value == 60) {
      return DeviceState.need_auth;
    } else if (value == 70) {
      return DeviceState.ip_config;
    } else if (value == 80) {
      return DeviceState.ip_check;
    } else if (value == 90) {
      return DeviceState.secondaries;
    } else if (value == 100) {
      return DeviceState.activated;
    } else if (value == 110) {
      return DeviceState.deactivating;
    } else if (value == 120) {
      return DeviceState.failed;
    } else {
      return DeviceState.unknown;
    }
  }

  bool get autoconnect => _object.getBooleanProperty(
      'org.freedesktop.NetworkManager.Device', 'Autoconnect');
  bool get firmwareMissing => _object.getBooleanProperty(
      'org.freedesktop.NetworkManager.Device', 'FirmwareMissing');
  bool get nmPluginMissing => _object.getBooleanProperty(
      'org.freedesktop.NetworkManager.Device', 'NmPluginMissing');
  DeviceType get deviceType {
    var value = _object.getUint32Property(
        'org.freedesktop.NetworkManager.Device', 'DeviceType');
    if (value == 1) {
      return DeviceType.ethernet;
    } else if (value == 2) {
      return DeviceType.wifi;
    } else if (value == 5) {
      return DeviceType.bluetooth;
    } else if (value == 6) {
      return DeviceType.olpc_mesh;
    } else if (value == 7) {
      return DeviceType.wimax;
    } else if (value == 8) {
      return DeviceType.modem;
    } else if (value == 9) {
      return DeviceType.infiniband;
    } else if (value == 10) {
      return DeviceType.bond;
    } else if (value == 11) {
      return DeviceType.vlan;
    } else if (value == 12) {
      return DeviceType.adsl;
    } else if (value == 13) {
      return DeviceType.bridge;
    } else if (value == 14) {
      return DeviceType.generic;
    } else if (value == 15) {
      return DeviceType.team;
    } else if (value == 16) {
      return DeviceType.tun;
    } else if (value == 17) {
      return DeviceType.ip_tunnel;
    } else if (value == 18) {
      return DeviceType.macvlan;
    } else if (value == 19) {
      return DeviceType.vxlan;
    } else if (value == 20) {
      return DeviceType.veth;
    } else if (value == 21) {
      return DeviceType.macsec;
    } else if (value == 22) {
      return DeviceType.dummy;
    } else if (value == 23) {
      return DeviceType.ppp;
    } else if (value == 24) {
      return DeviceType.ovs_interface;
    } else if (value == 25) {
      return DeviceType.ovs_port;
    } else if (value == 26) {
      return DeviceType.ovs_bridge;
    } else if (value == 27) {
      return DeviceType.wpan;
    } else if (value == 28) {
      return DeviceType._6lowpan;
    } else if (value == 29) {
      return DeviceType.wireguard;
    } else if (value == 30) {
      return DeviceType.wifi_p2p;
    } else if (value == 31) {
      return DeviceType.vrf;
    } else {
      return DeviceType.unknown;
    }
  }

  String get physicalPortId => _object.getStringProperty(
      'org.freedesktop.NetworkManager.Device', 'PhysicalPortId');
  int get mtu =>
      _object.getUint32Property('org.freedesktop.NetworkManager.Device', 'Mtu');
  int get metered => _object.getUint32Property(
      'org.freedesktop.NetworkManager.Device', 'Metered'); // FIXME: enum
  bool get real => _object.getBooleanProperty(
      'org.freedesktop.NetworkManager.Device', 'Real');
  int get interfaceFlags => _object.getUint32Property(
      'org.freedesktop.NetworkManager.Device', 'InterfaceFlags'); // FIXME: enum
  String get hwAddress => _object.getStringProperty(
      'org.freedesktop.NetworkManager.Device', 'HwAddress');
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

  List<NetworkManagerDevice> get devices {
    return _getDevices('Devices');
  }

  List<NetworkManagerDevice> get allDevices {
    return _getDevices('AllDevices');
  }

  List<NetworkManagerDevice> _getDevices(String propertyName) {
    if (_manager == null) {
      return null;
    }
    var deviceObjectPaths = _manager.getObjectPathArrayProperty(
        'org.freedesktop.NetworkManager', propertyName);
    var devices = List<NetworkManagerDevice>();
    for (var objectPath in deviceObjectPaths) {
      var device = _objects[objectPath];
      if (device != null) {
        devices.add(NetworkManagerDevice(device));
      }
    }

    return devices;
  }

  bool get networkingEnabled {
    if (_manager == null) {
      return null;
    }
    return _manager.getBooleanProperty(
        'org.freedesktop.NetworkManager', 'NetworkingEnabled');
  }

  bool get wirelessEnabled {
    if (_manager == null) {
      return null;
    }
    return _manager.getBooleanProperty(
        'org.freedesktop.NetworkManager', 'WirelessEnabled');
  }

  bool get wirelessHardwareEnabled {
    if (_manager == null) {
      return null;
    }
    return _manager.getBooleanProperty(
        'org.freedesktop.NetworkManager', 'WirelessHardwareEnabled');
  }

  bool get wwanEnabled {
    if (_manager == null) {
      return null;
    }
    return _manager.getBooleanProperty(
        'org.freedesktop.NetworkManager', 'WwanEnabled');
  }

  bool get wwanHardwareEnabled {
    if (_manager == null) {
      return null;
    }
    return _manager.getBooleanProperty(
        'org.freedesktop.NetworkManager', 'WwanHardwareEnabled');
  }

  /// Gets the version of NetworkManager running.
  String get version {
    if (_manager == null) {
      return null;
    }
    return _manager.getStringProperty(
        'org.freedesktop.NetworkManager', 'Version');
  }

  ConnectivityState get connectivity {
    var value = _manager.getUint32Property(
        'org.freedesktop.NetworkManager', 'Connectivity');
    if (value == 1) {
      return ConnectivityState.none;
    } else if (value == 2) {
      return ConnectivityState.portal;
    } else if (value == 3) {
      return ConnectivityState.limited;
    } else if (value == 4) {
      return ConnectivityState.full;
    } else {
      return ConnectivityState.unknown;
    }
  }

  bool get connectivityCheckEnabled {
    return _manager.getBooleanProperty(
        'org.freedesktop.NetworkManager', 'ConnectivityCheckEnabled');
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
