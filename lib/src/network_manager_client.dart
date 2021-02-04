import 'dart:async';

import 'package:dbus/dbus.dart';

/// Internet connectivity states.
enum NetworkManagerConnectivityState { unknown, none, portal, limited, full }

/// Device states.
enum NetworkManagerDeviceState {
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

/// Device types.
enum NetworkManagerDeviceType {
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

/// Traffic limitations.
enum NetworkManagerMetered { unknown, yes, no, guessYes, guessNo }

/// State of a [NetworkManagerActiveConnection].
enum NetworkManagerActiveConnectionState {
  unknown,
  activating,
  activated,
  deactivating,
  deactivated
}

/// Flags describing a [NetworkManagerActiveConnectionState].
enum NetworkManagerActivationStateFlag {
  isMaster,
  isSlave,
  layer2Ready,
  ip4Ready,
  ip6Ready,
  masterHasSlaves,
  lifetimeBoundToProfileVisibility,
  external
}

/// Flags for a [NetworkManagerSettingsConnection].
enum NetworkManagerConnectionFlag {
  unsaved,
  networkManagerGenerated,
  volatile,
  external
}

/// Capabilities of a [NetworkManagerDevice].
enum NetworkManagerDeviceCapability {
  networkManagerSupported,
  carrierDetect,
  isSoftware,
  singleRootIOVirtualization
}

/// Interface flags for a [NetworkManagerDevice].
enum NetworkManagerDeviceInterfaceFlag { up, lowerUp, carrier }

/// WiFi operating modes.
enum NetworkManagerWifiMode { unknown, adhoc, infra, ap, mesh }

NetworkManagerWifiMode _decodeWifiMode(int value) {
  if (value == 1) {
    return NetworkManagerWifiMode.adhoc;
  } else if (value == 2) {
    return NetworkManagerWifiMode.infra;
  } else if (value == 3) {
    return NetworkManagerWifiMode.ap;
  } else if (value == 4) {
    return NetworkManagerWifiMode.mesh;
  } else {
    return NetworkManagerWifiMode.unknown;
  }
}

/// Wifi capabilities.
enum NetworkManagerDeviceWifiCapability {
  cipherWEP40,
  cipherWEP104,
  cipherTKIP,
  cipherCCMP,
  wpa,
  rsn,
  ap,
  adhoc,
  freqValid,
  freq2GHz,
  freq5GHz,
  mesh,
  ibssRsn
}

/// Flags for a [NetworkManagerAccessPoint].
enum NetworkManagerWifiAcessPointFlag { privacy, wps, wpsPushButton, wpsPin }

/// Security flags for a [NetworkManagerAccessPoint].
enum NetworkManagerWifiAcessPointSecurityFlag {
  pairWEP40,
  pairWEP104,
  pairTKIP,
  pairCCMP,
  groupWEP40,
  groupWEP104,
  groupTKIP,
  groupCCMP,
  keyManagementPSK,
  keyManagement802_1X,
  keyManagementSAE,
  keyManagementOWE,
  keyManagementOWE_TM
}

List<NetworkManagerWifiAcessPointSecurityFlag>
    _decodeWifiAcessPointSecurityFlags(int value) {
  var flags = <NetworkManagerWifiAcessPointSecurityFlag>[];
  if ((value & 0x1) != 0) {
    flags.add(NetworkManagerWifiAcessPointSecurityFlag.pairWEP40);
  }
  if ((value & 0x2) != 0) {
    flags.add(NetworkManagerWifiAcessPointSecurityFlag.pairWEP104);
  }
  if ((value & 0x4) != 0) {
    flags.add(NetworkManagerWifiAcessPointSecurityFlag.pairTKIP);
  }
  if ((value & 0x8) != 0) {
    flags.add(NetworkManagerWifiAcessPointSecurityFlag.pairCCMP);
  }
  if ((value & 0x10) != 0) {
    flags.add(NetworkManagerWifiAcessPointSecurityFlag.groupWEP40);
  }
  if ((value & 0x20) != 0) {
    flags.add(NetworkManagerWifiAcessPointSecurityFlag.groupWEP104);
  }
  if ((value & 0x40) != 0) {
    flags.add(NetworkManagerWifiAcessPointSecurityFlag.groupTKIP);
  }
  if ((value & 0x80) != 0) {
    flags.add(NetworkManagerWifiAcessPointSecurityFlag.groupCCMP);
  }
  if ((value & 0x100) != 0) {
    flags.add(NetworkManagerWifiAcessPointSecurityFlag.keyManagementPSK);
  }
  if ((value & 0x200) != 0) {
    flags.add(NetworkManagerWifiAcessPointSecurityFlag.keyManagement802_1X);
  }
  if ((value & 0x400) != 0) {
    flags.add(NetworkManagerWifiAcessPointSecurityFlag.keyManagementSAE);
  }
  if ((value & 0x800) != 0) {
    flags.add(NetworkManagerWifiAcessPointSecurityFlag.keyManagementOWE);
  }
  if ((value & 0x1000) != 0) {
    flags.add(NetworkManagerWifiAcessPointSecurityFlag.keyManagementOWE_TM);
  }
  return flags;
}

/// Capabilities of a [NetworkManagerDeviceBluetooth].
enum NetworkManagerBluetoothCapability { dun, tun }

/// Settings profile manager.
class NetworkManagerSettings {
  final String settingsInterfaceName =
      'org.freedesktop.NetworkManager.Settings';

  final NetworkManagerClient client;
  final _NetworkManagerObject _object;

  NetworkManagerSettings(this.client, this._object);

  /// Stream of property names as their values change.
  Stream<List<String>> get propertiesChangedStream {
    return _object.interfaces[settingsInterfaceName]
        .propertiesChangedStreamController.stream;
  }

  /// Saved connections.
  List<NetworkManagerSettingsConnection> get connections {
    var objectPaths = _object.getObjectPathArrayProperty(
        settingsInterfaceName, 'Connections');
    var connections = <NetworkManagerSettingsConnection>[];
    for (var objectPath in objectPaths) {
      var connection = client._getConnection(objectPath);
      if (connection != null) {
        connections.add(connection);
      }
    }
    return connections;
  }

  /// The machine hostname.
  String get hostname =>
      _object.getStringProperty(settingsInterfaceName, 'Hostname');

  /// True if connections can be added or modified.
  bool get canModify =>
      _object.getBooleanProperty(settingsInterfaceName, 'CanModify');
}

/// Settings for a connection.
class NetworkManagerSettingsConnection {
  final String settingsConnectionInterfaceName =
      'org.freedesktop.NetworkManager.Settings.Connection';

  final _NetworkManagerObject _object;

  NetworkManagerSettingsConnection(this._object);

  /// Stream of property names as their values change.
  Stream<List<String>> get propertiesChangedStream {
    return _object.interfaces[settingsConnectionInterfaceName]
        .propertiesChangedStreamController.stream;
  }

  /// Updates the settings for this connection, writing them to persistent storage.
  void update(Map<String, Map<String, DBusValue>> properties) async {
    await _object.callMethod(settingsConnectionInterfaceName, 'Update', [
      DBusDict(
        DBusSignature('s'),
        DBusSignature('a{sv}'),
        properties.map(
          (key, value) => MapEntry(
            DBusString(key),
            DBusDict(
              DBusSignature('s'),
              DBusSignature('v'),
              value.map((k, v) => MapEntry(DBusString(k), DBusVariant(v))),
            ),
          ),
        ),
      )
    ]);
  }

  /// Updates the settings for this connection, not writing them to persistent storage.
  void updateUnsaved(Map<String, Map<String, DBusValue>> properties) async {
    await _object.callMethod(settingsConnectionInterfaceName, 'UpdateUnsaved', [
      DBusDict(
        DBusSignature('s'),
        DBusSignature('a{sv}'),
        properties.map(
          (key, value) => MapEntry(
            DBusString(key),
            DBusDict(
              DBusSignature('s'),
              DBusSignature('v'),
              value.map((k, v) => MapEntry(DBusString(k), DBusVariant(v))),
            ),
          ),
        ),
      )
    ]);
  }

  /// Deletes this network connection settings.
  Future<void> delete() async {
    await _object.callMethod(settingsConnectionInterfaceName, 'Delete', []);
  }

  /// Gets the settings belonging to this network connection.
  Future<Map<String, Map<String, DBusValue>>> getSettings() async {
    var result = await _object
        .callMethod(settingsConnectionInterfaceName, 'GetSettings', []);
    return (result.returnValues[0] as DBusDict).children.map(
          (key, value) => MapEntry(
            (key as DBusString).value,
            (value as DBusDict).children.map((k, v) =>
                MapEntry((k as DBusString).value, (v as DBusVariant).value)),
          ),
        );
  }

  /// Gets the secrets belonging to this network connection.
  Future<Map<String, Map<String, DBusValue>>> getSecrets(
      [String settingName = '']) async {
    var result = await _object.callMethod(settingsConnectionInterfaceName,
        'GetSecrets', [DBusString(settingName)]);
    return (result.returnValues[0] as DBusDict).children.map((key, value) =>
        MapEntry(
            (key as DBusString).value,
            (value as DBusDict).children.map((k, v) =>
                MapEntry((k as DBusString).value, (v as DBusVariant).value))));
  }

  /// Clears the secrets belonging to this network connection.
  void clearSecrets() async =>
      _object.callMethod(settingsConnectionInterfaceName, 'ClearSecrets', []);

  /// Saves the connection settings to persistent storage.
  void save() async =>
      _object.callMethod(settingsConnectionInterfaceName, 'Save', []);

  // FIXME: Update2

  /// True if the settings have yet to be written to persistent storage.
  bool get unsaved =>
      _object.getBooleanProperty(settingsConnectionInterfaceName, 'Unsaved');

  /// Flags associated with this connection.
  List<NetworkManagerConnectionFlag> get flags {
    var value =
        _object.getUint32Property(settingsConnectionInterfaceName, 'Flags');
    var flags = <NetworkManagerConnectionFlag>[];
    if ((value & 0x01) != 0) {
      flags.add(NetworkManagerConnectionFlag.unsaved);
    }
    if ((value & 0x02) != 0) {
      flags.add(NetworkManagerConnectionFlag.networkManagerGenerated);
    }
    if ((value & 0x04) != 0) {
      flags.add(NetworkManagerConnectionFlag.volatile);
    }
    if ((value & 0x08) != 0) {
      flags.add(NetworkManagerConnectionFlag.external);
    }
    return flags;
  }

  /// File that stores these settings.
  String get filename =>
      _object.getStringProperty(settingsConnectionInterfaceName, 'Filename');
}

class NetworkManagerDnsManager {
  final String dnsManagerInterfaceName =
      'org.freedesktop.NetworkManager.DnsManager';

  final _NetworkManagerObject _object;

  NetworkManagerDnsManager(this._object);

  /// Stream of property names as their values change.
  Stream<List<String>> get propertiesChangedStream {
    return _object.interfaces[dnsManagerInterfaceName]
        .propertiesChangedStreamController.stream;
  }

  String get mode => _object.getStringProperty(dnsManagerInterfaceName, 'Mode');
  String get rcManager =>
      _object.getStringProperty(dnsManagerInterfaceName, 'RcManager');
  List<Map<String, dynamic>> get configuration =>
      _object.getDataListProperty(dnsManagerInterfaceName, 'Configuration');
}

/// A device managed by NetworkManager.
class NetworkManagerDevice {
  final String deviceInterfaceName = 'org.freedesktop.NetworkManager.Device';

  final NetworkManagerClient client;
  final _NetworkManagerObject _object;

  /// Information for Bluetooth devices or null.
  final NetworkManagerDeviceBluetooth bluetooth;

  /// Generic device information or null.
  final NetworkManagerDeviceGeneric generic;

  /// Device statistics or null.
  final NetworkManagerDeviceStatistics statistics;

  /// TUN device information or null.
  final NetworkManagerDeviceTun tun;

  /// Information for VLAN devices or null.
  final NetworkManagerDeviceVlan vlan;

  /// Information for wired devices (e.g. Ethernet) or null.
  final NetworkManagerDeviceWired wired;

  /// Information for wireless devices (e.g WiFi) or null.
  final NetworkManagerDeviceWireless wireless;

  NetworkManagerDevice(this.client, this._object)
      : bluetooth = NetworkManagerDeviceBluetooth(_object),
        generic = NetworkManagerDeviceGeneric(_object),
        statistics = NetworkManagerDeviceStatistics(_object),
        tun = NetworkManagerDeviceTun(_object),
        vlan = NetworkManagerDeviceVlan(client, _object),
        wired = NetworkManagerDeviceWired(_object),
        wireless = NetworkManagerDeviceWireless(client, _object);

  /// Stream of property names as their values change.
  Stream<List<String>> get propertiesChangedStream {
    return _object.interfaces[deviceInterfaceName]
        .propertiesChangedStreamController.stream;
  }

  /// Disconnects a device and prevents the device from automatically activating further connections without user intervention.
  void disconnect() async =>
      _object.callMethod(deviceInterfaceName, 'Disconnect', []);

  /// Deletes a software device from NetworkManager and removes the interface from the system.
  /// The method returns an error when called for a hardware device.
  void delete() async => _object.callMethod(deviceInterfaceName, 'Delete', []);

  /// UDI for this device.
  String get udi => _object.getStringProperty(deviceInterfaceName, 'Udi');

  /// Device filesystem path.
  String get path => _object.getStringProperty(deviceInterfaceName, 'Path');

  String get ipInterface =>
      _object.getStringProperty(deviceInterfaceName, 'IpInterface');

  /// The kernel driver this device is using.
  String get driver => _object.getStringProperty(deviceInterfaceName, 'Driver');

  /// The version of the kernel driver this device is using.
  String get driverVersion =>
      _object.getStringProperty(deviceInterfaceName, 'DriverVersion');

  /// The version of the firmware this device is using.
  String get firmwareVersion =>
      _object.getStringProperty(deviceInterfaceName, 'FirmwareVersion');

  /// Capabilities of this device
  List<NetworkManagerDeviceCapability> get capabilities {
    var value = _object.getUint32Property(deviceInterfaceName, 'Capabilities');
    var values = <NetworkManagerDeviceCapability>[];
    if ((value & 0x01) != 0) {
      values.add(NetworkManagerDeviceCapability.networkManagerSupported);
    }
    if ((value & 0x02) != 0) {
      values.add(NetworkManagerDeviceCapability.carrierDetect);
    }
    if ((value & 0x03) != 0) {
      values.add(NetworkManagerDeviceCapability.isSoftware);
    }
    if ((value & 0x04) != 0) {
      values.add(NetworkManagerDeviceCapability.singleRootIOVirtualization);
    }
    return values;
  }

  /// The connection state of this device.
  NetworkManagerDeviceState get state {
    var value = _object.getUint32Property(deviceInterfaceName, 'State');
    if (value == 10) {
      return NetworkManagerDeviceState.unmanaged;
    } else if (value == 20) {
      return NetworkManagerDeviceState.unavailable;
    } else if (value == 30) {
      return NetworkManagerDeviceState.disconnected;
    } else if (value == 40) {
      return NetworkManagerDeviceState.prepare;
    } else if (value == 50) {
      return NetworkManagerDeviceState.config;
    } else if (value == 60) {
      return NetworkManagerDeviceState.need_auth;
    } else if (value == 70) {
      return NetworkManagerDeviceState.ip_config;
    } else if (value == 80) {
      return NetworkManagerDeviceState.ip_check;
    } else if (value == 90) {
      return NetworkManagerDeviceState.secondaries;
    } else if (value == 100) {
      return NetworkManagerDeviceState.activated;
    } else if (value == 110) {
      return NetworkManagerDeviceState.deactivating;
    } else if (value == 120) {
      return NetworkManagerDeviceState.failed;
    } else {
      return NetworkManagerDeviceState.unknown;
    }
  }

  // FIXME: StateReason

  /// Connection that owns this device.
  NetworkManagerActiveConnection get activeConnection {
    var objectPath =
        _object.getObjectPathProperty(deviceInterfaceName, 'ActiveConnection');
    return client._getActiveConnection(objectPath);
  }

  /// IPv4 configuration for this device.
  NetworkManagerIP4Config get ip4Config {
    var objectPath =
        _object.getObjectPathProperty(deviceInterfaceName, 'Ip4Config');
    return client._getIP4Config(objectPath);
  }

  /// DHCPv4 configuration for this device.
  NetworkManagerDHCP4Config get dhcp4Config {
    var objectPath =
        _object.getObjectPathProperty(deviceInterfaceName, 'DHCP4Config');
    return client._getDHCP4Config(objectPath);
  }

  /// IPv6 configuration for this device.
  NetworkManagerIP6Config get ip6Config {
    var objectPath =
        _object.getObjectPathProperty(deviceInterfaceName, 'Ip6Config');
    return client._getIP6Config(objectPath);
  }

  /// DHCPv6 configuration for this device.
  NetworkManagerDHCP6Config get dhcp6Config {
    var objectPath =
        _object.getObjectPathProperty(deviceInterfaceName, 'DHCP6Config');
    return client._getDHCP6Config(objectPath);
  }

  /// True if this device is being managed by NetworkManager.
  bool get managed =>
      _object.getBooleanProperty(deviceInterfaceName, 'Managed');

  /// Sets if this device is being managed by NetworkManager.
  set managed(bool value) =>
      _object.setProperty(deviceInterfaceName, 'Managed', DBusBoolean(value));

  /// True if this device is allowed to automatically connect.
  bool get autoconnect =>
      _object.getBooleanProperty(deviceInterfaceName, 'Autoconnect');

  /// Sets if this device is allowed to automatically connect.
  set autoconnect(bool value) => _object.setProperty(
      deviceInterfaceName, 'Autoconnect', DBusBoolean(value));

  /// True if this device is missing firware required for it to operate.
  bool get firmwareMissing =>
      _object.getBooleanProperty(deviceInterfaceName, 'FirmwareMissing');

  /// True if this device is missing a plugin or needs plugin configuration for it to operate.
  bool get nmPluginMissing =>
      _object.getBooleanProperty(deviceInterfaceName, 'NmPluginMissing');

  /// The type of device.
  NetworkManagerDeviceType get deviceType {
    var value = _object.getUint32Property(
      deviceInterfaceName,
      'DeviceType',
    );
    if (value == 1) {
      return NetworkManagerDeviceType.ethernet;
    } else if (value == 2) {
      return NetworkManagerDeviceType.wifi;
    } else if (value == 5) {
      return NetworkManagerDeviceType.bluetooth;
    } else if (value == 6) {
      return NetworkManagerDeviceType.olpc_mesh;
    } else if (value == 7) {
      return NetworkManagerDeviceType.wimax;
    } else if (value == 8) {
      return NetworkManagerDeviceType.modem;
    } else if (value == 9) {
      return NetworkManagerDeviceType.infiniband;
    } else if (value == 10) {
      return NetworkManagerDeviceType.bond;
    } else if (value == 11) {
      return NetworkManagerDeviceType.vlan;
    } else if (value == 12) {
      return NetworkManagerDeviceType.adsl;
    } else if (value == 13) {
      return NetworkManagerDeviceType.bridge;
    } else if (value == 14) {
      return NetworkManagerDeviceType.generic;
    } else if (value == 15) {
      return NetworkManagerDeviceType.team;
    } else if (value == 16) {
      return NetworkManagerDeviceType.tun;
    } else if (value == 17) {
      return NetworkManagerDeviceType.ip_tunnel;
    } else if (value == 18) {
      return NetworkManagerDeviceType.macvlan;
    } else if (value == 19) {
      return NetworkManagerDeviceType.vxlan;
    } else if (value == 20) {
      return NetworkManagerDeviceType.veth;
    } else if (value == 21) {
      return NetworkManagerDeviceType.macsec;
    } else if (value == 22) {
      return NetworkManagerDeviceType.dummy;
    } else if (value == 23) {
      return NetworkManagerDeviceType.ppp;
    } else if (value == 24) {
      return NetworkManagerDeviceType.ovs_interface;
    } else if (value == 25) {
      return NetworkManagerDeviceType.ovs_port;
    } else if (value == 26) {
      return NetworkManagerDeviceType.ovs_bridge;
    } else if (value == 27) {
      return NetworkManagerDeviceType.wpan;
    } else if (value == 28) {
      return NetworkManagerDeviceType._6lowpan;
    } else if (value == 29) {
      return NetworkManagerDeviceType.wireguard;
    } else if (value == 30) {
      return NetworkManagerDeviceType.wifi_p2p;
    } else if (value == 31) {
      return NetworkManagerDeviceType.vrf;
    } else {
      return NetworkManagerDeviceType.unknown;
    }
  }

  // FIXME: AvailableConnections
  String get physicalPortId =>
      _object.getStringProperty(deviceInterfaceName, 'PhysicalPortId');

  /// The device MTU.
  int get mtu => _object.getUint32Property(deviceInterfaceName, 'Mtu');

  /// True if the device has traffic limitations.
  NetworkManagerMetered get metered => NetworkManagerMetered
      .values[_object.getUint32Property(deviceInterfaceName, 'Metered')];

  // FIXME: LldpNeighbors
  bool get real => _object.getBooleanProperty(deviceInterfaceName, 'Real');

  // FIXME: Ip4Connectivity

  // FIXME: Ip6Connectivity

  /// Flags for network interfaces.
  List<NetworkManagerDeviceInterfaceFlag> get interfaceFlags {
    var value =
        _object.getUint32Property(deviceInterfaceName, 'InterfaceFlags');
    var flags = <NetworkManagerDeviceInterfaceFlag>[];
    if ((value & 0x01) != 0) {
      flags.add(NetworkManagerDeviceInterfaceFlag.up);
    }
    if ((value & 0x02) != 0) {
      flags.add(NetworkManagerDeviceInterfaceFlag.lowerUp);
    }
    if ((value & 0x10000) != 0) {
      flags.add(NetworkManagerDeviceInterfaceFlag.carrier);
    }
    return flags;
  }

  /// Hardware address for this device.
  String get hwAddress =>
      _object.getStringProperty(deviceInterfaceName, 'HwAddress');
}

/// Information for Bluetooth devices.
class NetworkManagerDeviceBluetooth {
  final String bluetoothDeviceInterfaceName =
      'org.freedesktop.NetworkManager.Device.Bluetooth';

  final _NetworkManagerObject _object;

  NetworkManagerDeviceBluetooth(this._object);

  /// Stream of property names as their values change.
  Stream<List<String>> get propertiesChangedStream {
    return _object.interfaces[bluetoothDeviceInterfaceName]
        .propertiesChangedStreamController.stream;
  }

  /// Bluetooth capabilities of this device.
  List<NetworkManagerBluetoothCapability> get btCapabilities {
    var value = _object.getUint32Property(
        bluetoothDeviceInterfaceName, 'BtCapabilities');
    var flags = <NetworkManagerBluetoothCapability>[];
    if ((value & 0x1) != 0) {
      flags.add(NetworkManagerBluetoothCapability.dun);
    }
    if ((value & 0x2) != 0) {
      flags.add(NetworkManagerBluetoothCapability.tun);
    }
    return flags;
  }
}

/// Information for generic devices.
class NetworkManagerDeviceGeneric {
  final String genericDeviceInterfaceName =
      'org.freedesktop.NetworkManager.Device.Generic';

  final _NetworkManagerObject _object;

  NetworkManagerDeviceGeneric(this._object);

  /// Stream of property names as their values change.
  Stream<List<String>> get propertiesChangedStream {
    return _object.interfaces[genericDeviceInterfaceName]
        .propertiesChangedStreamController.stream;
  }

  String get typeDescription =>
      _object.getStringProperty(genericDeviceInterfaceName, 'TypeDescription');
}

/// Statistics for devices.
class NetworkManagerDeviceStatistics {
  final String statisticsDeviceInterfaceName =
      'org.freedesktop.NetworkManager.Device.Statistics';

  final _NetworkManagerObject _object;

  NetworkManagerDeviceStatistics(this._object);

  /// Stream of property names as their values change.
  Stream<List<String>> get propertiesChangedStream {
    return _object.interfaces[statisticsDeviceInterfaceName]
        .propertiesChangedStreamController.stream;
  }

  int get refreshRateMs =>
      _object.getUint32Property(statisticsDeviceInterfaceName, 'RefreshRateMs');

  /// How many bytes have been transmitted.
  int get txBytes =>
      _object.getUint64Property(statisticsDeviceInterfaceName, 'TxBytes');

  /// How many bytes have been received.
  int get rxBytes =>
      _object.getUint64Property(statisticsDeviceInterfaceName, 'RxBytes');
}

/// Information for TUN devices.
class NetworkManagerDeviceTun {
  final String tunDeviceInterfaceName =
      'org.freedesktop.NetworkManager.Device.Tun';

  final _NetworkManagerObject _object;

  NetworkManagerDeviceTun(this._object);

  /// Stream of property names as their values change.
  Stream<List<String>> get propertiesChangedStream {
    return _object.interfaces[tunDeviceInterfaceName]
        .propertiesChangedStreamController.stream;
  }

  String get permHwAddress =>
      _object.getStringProperty(tunDeviceInterfaceName, 'PermHwAddress');

  int get owner => _object.getInt64Property(tunDeviceInterfaceName, 'Owner');

  int get group => _object.getInt64Property(tunDeviceInterfaceName, 'Group');

  bool get noPi => _object.getBooleanProperty(tunDeviceInterfaceName, 'NoPi');

  bool get vnetHdr =>
      _object.getBooleanProperty(tunDeviceInterfaceName, 'VnetHdr');

  bool get multiQueue =>
      _object.getBooleanProperty(tunDeviceInterfaceName, 'MultiQueue');
}

class NetworkManagerDeviceVlan {
  final String vlanDeviceInterfaceName =
      'org.freedesktop.NetworkManager.Device.Vlan';

  final NetworkManagerClient client;
  final _NetworkManagerObject _object;

  NetworkManagerDeviceVlan(this.client, this._object);

  /// Stream of property names as their values change.
  Stream<List<String>> get propertiesChangedStream {
    return _object.interfaces[vlanDeviceInterfaceName]
        .propertiesChangedStreamController.stream;
  }

  NetworkManagerDevice get parent {
    var objectPath =
        _object.getObjectPathProperty(vlanDeviceInterfaceName, 'Parent');
    return client._getDevice(objectPath);
  }

  int get vlanId =>
      _object.getUint32Property(vlanDeviceInterfaceName, 'VlanId');
}

class NetworkManagerDeviceWired {
  final String wiredDeviceInterfaceName =
      'org.freedesktop.NetworkManager.Device.Wired';

  final _NetworkManagerObject _object;

  NetworkManagerDeviceWired(this._object);

  String get permHwAddress =>
      _object.getStringProperty(wiredDeviceInterfaceName, 'PermHwAddress');
  int get speed => _object.getUint32Property(wiredDeviceInterfaceName, 'Speed');
  List<String> get s390Subchannels => _object.getStringArrayProperty(
      wiredDeviceInterfaceName, 'S390Subchannels');
}

class NetworkManagerDeviceWireless {
  final String wirelessDeviceInterfaceName =
      'org.freedesktop.NetworkManager.Device.Wireless';

  final NetworkManagerClient client;
  final _NetworkManagerObject _object;

  NetworkManagerDeviceWireless(this.client, this._object);

  /// Stream of property names as their values change.
  Stream<List<String>> get propertiesChangedStream {
    return _object.interfaces[wirelessDeviceInterfaceName]
        .propertiesChangedStreamController.stream;
  }

  /// Permanent hardware address, e.g. '00:0a:95:9d:68:16'
  String get permHwAddress =>
      _object.getStringProperty(wirelessDeviceInterfaceName, 'PermHwAddress');

  /// Operating mode of the device.
  NetworkManagerWifiMode get mode {
    var value = _object.getUint32Property(wirelessDeviceInterfaceName, 'Mode');
    return _decodeWifiMode(value);
  }

  // Bitrate of currently in use, in kilobits/second.
  int get bitrate =>
      _object.getUint32Property(wirelessDeviceInterfaceName, 'Bitrate');

  /// Access points available on this device.
  List<NetworkManagerAccessPoint> get accessPoints {
    var objectPaths = _object.getObjectPathArrayProperty(
        wirelessDeviceInterfaceName, 'AccessPoints');
    var accessPoints = <NetworkManagerAccessPoint>[];
    for (var objectPath in objectPaths) {
      var accessPoint = client._getAccessPoint(objectPath);
      if (accessPoint != null) {
        accessPoints.add(accessPoint);
      }
    }

    return accessPoints;
  }

  /// Access point currently in use.
  NetworkManagerAccessPoint get activeAccessPoint {
    var objectPath = _object.getObjectPathProperty(
        wirelessDeviceInterfaceName, 'ActiveAccessPoint');
    return client._getAccessPoint(objectPath);
  }

  /// Device capabilities.
  List<NetworkManagerDeviceWifiCapability> get wirelessCapabilities {
    var value = _object.getUint32Property(
        wirelessDeviceInterfaceName, 'WirelessCapabilities');
    var flags = <NetworkManagerDeviceWifiCapability>[];
    if ((value & 0x1) != 0) {
      flags.add(NetworkManagerDeviceWifiCapability.cipherWEP40);
    }
    if ((value & 0x2) != 0) {
      flags.add(NetworkManagerDeviceWifiCapability.cipherWEP104);
    }
    if ((value & 0x4) != 0) {
      flags.add(NetworkManagerDeviceWifiCapability.cipherTKIP);
    }
    if ((value & 0x8) != 0) {
      flags.add(NetworkManagerDeviceWifiCapability.cipherCCMP);
    }
    if ((value & 0x10) != 0) {
      flags.add(NetworkManagerDeviceWifiCapability.wpa);
    }
    if ((value & 0x20) != 0) {
      flags.add(NetworkManagerDeviceWifiCapability.rsn);
    }
    if ((value & 0x40) != 0) {
      flags.add(NetworkManagerDeviceWifiCapability.ap);
    }
    if ((value & 0x80) != 0) {
      flags.add(NetworkManagerDeviceWifiCapability.adhoc);
    }
    if ((value & 0x100) != 0) {
      flags.add(NetworkManagerDeviceWifiCapability.freqValid);
    }
    if ((value & 0x200) != 0) {
      flags.add(NetworkManagerDeviceWifiCapability.freq2GHz);
    }
    if ((value & 0x400) != 0) {
      flags.add(NetworkManagerDeviceWifiCapability.freq5GHz);
    }
    if ((value & 0x1000) != 0) {
      flags.add(NetworkManagerDeviceWifiCapability.mesh);
    }
    if ((value & 0x2000) != 0) {
      flags.add(NetworkManagerDeviceWifiCapability.ibssRsn);
    }
    return flags;
  }

  /// Last time this device completed a network scan in milliseconds since boot. -1 if has never scanned for access points.
  int get lastScan =>
      _object.getInt64Property(wirelessDeviceInterfaceName, 'LastScan');

  /// Request this device to scan for access points.
  Future requestScan([Map<String, DBusValue> options = const {}]) async {
    var args = [
      DBusDict(
          DBusSignature('s'),
          DBusSignature('v'),
          options.map(
              (name, value) => MapEntry(DBusString(name), DBusVariant(value))))
    ];
    var result = await _object.callMethod(
        wirelessDeviceInterfaceName, 'RequestScan', args);
    var values = result.returnValues;
    if (values.isNotEmpty) {
      throw 'RequestScan returned invalid result: ${values}';
    }
  }
}

class NetworkManagerActiveConnection {
  final String activeConnectionInterfaceName =
      'org.freedesktop.NetworkManager.Connection.Active';

  final NetworkManagerClient client;
  final _NetworkManagerObject _object;

  NetworkManagerActiveConnection(this.client, this._object);

  /// Stream of property names as their values change.
  Stream<List<String>> get propertiesChangedStream {
    return _object.interfaces[activeConnectionInterfaceName]
        .propertiesChangedStreamController.stream;
  }

  /// The connection settings.
  NetworkManagerSettingsConnection get connection {
    var objectPath = _object.getObjectPathProperty(
      activeConnectionInterfaceName,
      'Connection',
    );
    return client._getConnection(objectPath);
  }

  /// ID for this connection, e.g. 'Ethernet', 'my-cool-wifi'.
  String get id =>
      _object.getStringProperty(activeConnectionInterfaceName, 'Id');

  /// Unique ID for this connection, e.g. '123e4567-e89b-12d3-a456-426614174000'.
  String get uuid =>
      _object.getStringProperty(activeConnectionInterfaceName, 'Uuid');

  /// Type of this connection, e.g. '802-11-wireless', '802-3-ethernet'.
  String get type =>
      _object.getStringProperty(activeConnectionInterfaceName, 'type');

  /// The state of this connection.
  NetworkManagerActiveConnectionState get state {
    var value =
        _object.getUint32Property(activeConnectionInterfaceName, 'State');
    if (value == 1) {
      return NetworkManagerActiveConnectionState.activating;
    } else if (value == 2) {
      return NetworkManagerActiveConnectionState.activated;
    } else if (value == 3) {
      return NetworkManagerActiveConnectionState.deactivating;
    } else if (value == 4) {
      return NetworkManagerActiveConnectionState.deactivated;
    } else {
      return NetworkManagerActiveConnectionState.unknown;
    }
  }

  /// Flags related to [state].
  List<NetworkManagerActivationStateFlag> get stateFlags {
    var value =
        _object.getUint32Property(activeConnectionInterfaceName, 'StateFlags');
    var flags = <NetworkManagerActivationStateFlag>[];
    if ((value & 0x01) != 0) {
      flags.add(NetworkManagerActivationStateFlag.isMaster);
    }
    if ((value & 0x02) != 0) {
      flags.add(NetworkManagerActivationStateFlag.isSlave);
    }
    if ((value & 0x04) != 0) {
      flags.add(NetworkManagerActivationStateFlag.layer2Ready);
    }
    if ((value & 0x08) != 0) {
      flags.add(NetworkManagerActivationStateFlag.ip4Ready);
    }
    if ((value & 0x10) != 0) {
      flags.add(NetworkManagerActivationStateFlag.ip6Ready);
    }
    if ((value & 0x20) != 0) {
      flags.add(NetworkManagerActivationStateFlag.masterHasSlaves);
    }
    if ((value & 0x40) != 0) {
      flags.add(
          NetworkManagerActivationStateFlag.lifetimeBoundToProfileVisibility);
    }
    if ((value & 0x80) != 0) {
      flags.add(NetworkManagerActivationStateFlag.external);
    }
    return flags;
  }

  /// True if this is the default IPv4 connection.
  bool get default4 =>
      _object.getBooleanProperty(activeConnectionInterfaceName, 'Default');

  /// IPv4 configuration for this connection.
  NetworkManagerIP4Config get ip4Config {
    var objectPath = _object.getObjectPathProperty(
      activeConnectionInterfaceName,
      'Ip4Config',
    );
    return client._getIP4Config(objectPath);
  }

  /// DHCPv4 configuration for this connection.
  NetworkManagerDHCP4Config get dhcp4Config {
    var objectPath = _object.getObjectPathProperty(
      activeConnectionInterfaceName,
      'DHCP4Config',
    );
    return client._getDHCP4Config(objectPath);
  }

  /// True if this is the default IPv6 connection.
  bool get default6 =>
      _object.getBooleanProperty(activeConnectionInterfaceName, 'Default6');

  /// IPv6 configuration for this connection.
  NetworkManagerIP6Config get ip6Config {
    var objectPath = _object.getObjectPathProperty(
      activeConnectionInterfaceName,
      'Ip6Config',
    );
    return client._getIP6Config(objectPath);
  }

  /// DHCPv6 configuration for this connection.
  NetworkManagerDHCP6Config get dhcp6Config {
    var objectPath = _object.getObjectPathProperty(
      activeConnectionInterfaceName,
      'DHCP6Config',
    );
    return client._getDHCP6Config(objectPath);
  }

  /// True if this is a VPN connection.
  bool get vpn => _object.getBooleanProperty(
        activeConnectionInterfaceName,
        'Vpn',
      );

  /// Devices this connection uses.
  List<NetworkManagerDevice> get devices {
    var deviceObjectPaths = _object.getObjectPathArrayProperty(
      activeConnectionInterfaceName,
      'Devices',
    );
    var devices = <NetworkManagerDevice>[];
    for (var objectPath in deviceObjectPaths) {
      var device = client._getDevice(objectPath);
      if (device != null) {
        devices.add(device);
      }
    }
    return devices;
  }

  /// Master device if this connection is a slave.
  NetworkManagerDevice get master {
    var objectPath = _object.getObjectPathProperty(
      activeConnectionInterfaceName,
      'Master',
    );
    return client._getDevice(objectPath);
  }
}

class NetworkManagerIP4Config {
  final String ip4ConfigInterfaceName =
      'org.freedesktop.NetworkManager.IP4Config';

  final _NetworkManagerObject _object;

  NetworkManagerIP4Config(this._object);

  /// Stream of property names as their values change.
  Stream<List<String>> get propertiesChangedStream {
    return _object.interfaces[ip4ConfigInterfaceName]
        .propertiesChangedStreamController.stream;
  }

  List<Map<String, dynamic>> get addressData =>
      _object.getDataListProperty(ip4ConfigInterfaceName, 'AddressData');
  String get gateway =>
      _object.getStringProperty(ip4ConfigInterfaceName, 'Gateway');
  List<Map<String, dynamic>> get routeData =>
      _object.getDataListProperty(ip4ConfigInterfaceName, 'RouteData');
  List<Map<String, dynamic>> get nameServerData =>
      _object.getDataListProperty(ip4ConfigInterfaceName, 'NameServerData');
  List<String> get domains =>
      _object.getStringArrayProperty(ip4ConfigInterfaceName, 'Domains');
  List<String> get searches =>
      _object.getStringArrayProperty(ip4ConfigInterfaceName, 'Searches');
  List<String> get dnsOptions =>
      _object.getStringArrayProperty(ip4ConfigInterfaceName, 'DnsOptions');
  int get dnsPriority =>
      _object.getInt32Property(ip4ConfigInterfaceName, 'DnsPriority');
  List<Map<String, dynamic>> get winsServerData =>
      _object.getDataListProperty(ip4ConfigInterfaceName, 'WinsServerData');
}

class NetworkManagerDHCP4Config {
  final String dhcp4ConfigInterfaceName =
      'org.freedesktop.NetworkManager.DHCP4Config';

  final _NetworkManagerObject _object;

  NetworkManagerDHCP4Config(this._object);

  /// Stream of property names as their values change.
  Stream<List<String>> get propertiesChangedStream {
    return _object.interfaces[dhcp4ConfigInterfaceName]
        .propertiesChangedStreamController.stream;
  }

  Map<String, dynamic> get options {
    var value = _object.getCachedProperty(dhcp4ConfigInterfaceName, 'Options');
    if (value == null) {
      return {};
    }
    if (value.signature != DBusSignature('a{sv}')) {
      return {};
    }
    return (value as DBusDict).children.map((key, value) => MapEntry(
        (key as DBusString).value, (value as DBusVariant).value.toNative()));
  }
}

class NetworkManagerIP6Config {
  final String ip6ConfigInterfaceName =
      'org.freedesktop.NetworkManager.IP6Config';

  final _NetworkManagerObject _object;

  NetworkManagerIP6Config(this._object);

  /// Stream of property names as their values change.
  Stream<List<String>> get propertiesChangedStream {
    return _object.interfaces[ip6ConfigInterfaceName]
        .propertiesChangedStreamController.stream;
  }

  List<Map<String, dynamic>> get addressData =>
      _object.getDataListProperty(ip6ConfigInterfaceName, 'AddressData');
  String get gateway =>
      _object.getStringProperty(ip6ConfigInterfaceName, 'Gateway');
  List<Map<String, dynamic>> get routeData =>
      _object.getDataListProperty(ip6ConfigInterfaceName, 'RouteData');
  List<Map<String, dynamic>> get nameServerData =>
      _object.getDataListProperty(ip6ConfigInterfaceName, 'NameServerData');
  List<String> get domains =>
      _object.getStringArrayProperty(ip6ConfigInterfaceName, 'Domains');
  List<String> get searches =>
      _object.getStringArrayProperty(ip6ConfigInterfaceName, 'Searches');
  List<String> get dnsOptions =>
      _object.getStringArrayProperty(ip6ConfigInterfaceName, 'DnsOptions');
  int get dnsPriority =>
      _object.getInt32Property(ip6ConfigInterfaceName, 'DnsPriority');
}

class NetworkManagerDHCP6Config {
  final String dhcp6ConfigInterfaceName =
      'org.freedesktop.NetworkManager.DHCP6Config';

  final _NetworkManagerObject _object;

  NetworkManagerDHCP6Config(this._object);

  /// Stream of property names as their values change.
  Stream<List<String>> get propertiesChangedStream {
    return _object.interfaces[dhcp6ConfigInterfaceName]
        .propertiesChangedStreamController.stream;
  }

  Map<String, dynamic> get options {
    var value = _object.getCachedProperty(dhcp6ConfigInterfaceName, 'Options');
    if (value == null) {
      return {};
    }
    if (value.signature != DBusSignature('a{sv}')) {
      return {};
    }
    return (value as DBusDict).children.map((key, value) => MapEntry(
        (key as DBusString).value, (value as DBusVariant).value.toNative()));
  }
}

class NetworkManagerAccessPoint {
  final String accessPointInterfaceName =
      'org.freedesktop.NetworkManager.AccessPoint';

  final _NetworkManagerObject _object;

  NetworkManagerAccessPoint(this._object);

  /// Stream of property names as their values change.
  Stream<List<String>> get propertiesChangedStream {
    return _object.interfaces[accessPointInterfaceName]
        .propertiesChangedStreamController.stream;
  }

  /// Capabilities of this access point.
  List<NetworkManagerWifiAcessPointFlag> get flags {
    var value = _object.getUint32Property(accessPointInterfaceName, 'Flags');
    var flags = <NetworkManagerWifiAcessPointFlag>[];
    if ((value & 0x01) != 0) {
      flags.add(NetworkManagerWifiAcessPointFlag.privacy);
    }
    if ((value & 0x02) != 0) {
      flags.add(NetworkManagerWifiAcessPointFlag.wps);
    }
    if ((value & 0x04) != 0) {
      flags.add(NetworkManagerWifiAcessPointFlag.wpsPushButton);
    }
    if ((value & 0x08) != 0) {
      flags.add(NetworkManagerWifiAcessPointFlag.wpsPin);
    }
    return flags;
  }

  /// WPA security capabilities of this access point.
  List<NetworkManagerWifiAcessPointSecurityFlag> get wpaFlags {
    var value = _object.getUint32Property(accessPointInterfaceName, 'WpaFlags');
    return _decodeWifiAcessPointSecurityFlags(value);
  }

  /// RSN security capabilities of this access point.
  List<NetworkManagerWifiAcessPointSecurityFlag> get rsnFlags {
    var value = _object.getUint32Property(accessPointInterfaceName, 'RsnFlags');
    return _decodeWifiAcessPointSecurityFlags(value);
  }

  /// SSID advertised by the access point.
  /// Note this is in binary form, but is likely to contain a text string.
  List<int> get ssid {
    var value = _object.getCachedProperty(accessPointInterfaceName, 'Ssid');
    if (value == null) {
      return [];
    }
    if (value.signature != DBusSignature('ay')) {
      return [];
    }
    return (value as DBusArray)
        .children
        .map((e) => (e as DBusByte).value)
        .toList();
  }

  /// Radio frequency of this access point in MHz.
  int get frequency =>
      _object.getUint32Property(accessPointInterfaceName, 'Frequency');

  /// The hardware address (BSSID) of this access point.
  String get hwAddress =>
      _object.getStringProperty(accessPointInterfaceName, 'HwAddress');

  /// Mode this access point is operating in.
  NetworkManagerWifiMode get mode {
    var value = _object.getUint32Property(accessPointInterfaceName, 'Mode');
    return _decodeWifiMode(value);
  }

  /// Maximum bitrate this access point is capable of in kilobits/second.
  int get maxBitrate =>
      _object.getUint32Property(accessPointInterfaceName, 'MaxBitrate');

  /// Signal quality of access point in percent.
  int get strength =>
      _object.getByteProperty(accessPointInterfaceName, 'Strength');

  /// Last time this access point was seen in a scan in seconds since boot.
  int get lastSeen =>
      _object.getInt32Property(accessPointInterfaceName, 'LastSeen');
}

class _NetworkManagerInterface {
  final Map<String, DBusValue> properties;
  final propertiesChangedStreamController =
      StreamController<List<String>>.broadcast();

  /// Stream of property names as their values change.
  Stream<List<String>> get propertiesChangedStream =>
      propertiesChangedStreamController.stream;

  _NetworkManagerInterface(this.properties);

  void updateProperties(Map<String, DBusValue> changedProperties) {
    properties.addAll(changedProperties);
    propertiesChangedStreamController.add(changedProperties.keys.toList());
  }
}

class _NetworkManagerObject extends DBusRemoteObject {
  final interfaces = <String, _NetworkManagerInterface>{};

  void updateInterfaces(
      Map<String, Map<String, DBusValue>> interfacesAndProperties) {
    interfacesAndProperties.forEach((interfaceName, properties) {
      interfaces[interfaceName] = _NetworkManagerInterface(properties);
    });
  }

  void removeInterfaces(List<String> interfaceNames) {
    for (var interfaceName in interfaceNames) {
      interfaces.remove(interfaceName);
    }
  }

  void updateProperties(
      String interfaceName, Map<String, DBusValue> changedProperties) {
    var interface = interfaces[interfaceName];
    if (interface != null) {
      interface.updateProperties(changedProperties);
    }
  }

  /// Gets a cached property.
  DBusValue getCachedProperty(String interfaceName, String name) {
    var interface = interfaces[interfaceName];
    if (interface == null) {
      return null;
    }
    return interface.properties[name];
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

  /// Gets a cached unsigned 8 bit integer property, or returns null if not present or not the correct type.
  int getByteProperty(String interface, String name) {
    var value = getCachedProperty(interface, name);
    if (value == null) {
      return null;
    }
    if (value.signature != DBusSignature('y')) {
      return null;
    }
    return (value as DBusByte).value;
  }

  /// Gets a cached signed 32 bit integer property, or returns null if not present or not the correct type.
  int getInt32Property(String interface, String name) {
    var value = getCachedProperty(interface, name);
    if (value == null) {
      return null;
    }
    if (value.signature != DBusSignature('i')) {
      return null;
    }
    return (value as DBusInt32).value;
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

  /// Gets a cached signed 64 bit integer property, or returns null if not present or not the correct type.
  int getInt64Property(String interface, String name) {
    var value = getCachedProperty(interface, name);
    if (value == null) {
      return null;
    }
    if (value.signature != DBusSignature('x')) {
      return null;
    }
    return (value as DBusInt64).value;
  }

  /// Gets a cached unsigned 64 bit integer property, or returns null if not present or not the correct type.
  int getUint64Property(String interface, String name) {
    var value = getCachedProperty(interface, name);
    if (value == null) {
      return null;
    }
    if (value.signature != DBusSignature('t')) {
      return null;
    }
    return (value as DBusUint64).value;
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

  /// Gets a cached string array property, or returns null if not present or not the correct type.
  List<String> getStringArrayProperty(String interface, String name) {
    var value = getCachedProperty(interface, name);
    if (value == null) {
      return null;
    }
    if (value.signature != DBusSignature('as')) {
      return null;
    }
    return (value as DBusArray)
        .children
        .map((e) => (e as DBusString).value)
        .toList();
  }

  /// Gets a cached object path property, or returns null if not present or not the correct type.
  DBusObjectPath getObjectPathProperty(String interface, String name) {
    var value = getCachedProperty(interface, name);
    if (value == null) {
      return null;
    }
    if (value.signature != DBusSignature('o')) {
      return null;
    }
    return (value as DBusObjectPath);
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

  /// Gets a cached list of data property, or returns null if not present or not the correct type.
  List<Map<String, dynamic>> getDataListProperty(
      String interface, String name) {
    var value = getCachedProperty(interface, name);
    if (value == null) {
      return null;
    }
    if (value.signature != DBusSignature('aa{sv}')) {
      return null;
    }
    Map<String, dynamic> convertData(DBusValue value) {
      return (value as DBusDict).children.map((key, value) => MapEntry(
            (key as DBusString).value,
            (value as DBusVariant).value.toNative(),
          ));
    }

    return (value as DBusArray)
        .children
        .map((value) => convertData(value))
        .toList();
  }

  _NetworkManagerObject(DBusClient client, DBusObjectPath path,
      Map<String, Map<String, DBusValue>> interfacesAndProperties)
      : super(client, 'org.freedesktop.NetworkManager', path) {
    updateInterfaces(interfacesAndProperties);
  }
}

/// A client that connects to NetworkManager.
class NetworkManagerClient {
  final String managerInterfaceName = 'org.freedesktop.NetworkManager';

  /// The bus this client is connected to.
  final DBusClient systemBus;

  /// The root D-Bus NetworkManager object at path '/org/freedesktop'.
  DBusRemoteObject _root;

  // Objects exported on the bus.
  final _objects = <DBusObjectPath, _NetworkManagerObject>{};

  // Subscription to object manager signals.
  StreamSubscription _objectManagerSubscription;

  /// Creates a new NetworkManager client connected to the system D-Bus.
  NetworkManagerClient(this.systemBus);

  /// Stream of property names as their values change.
  Stream<List<String>> get propertiesChangedStream {
    if (_manager == null) {
      return null;
    }
    return _manager.interfaces['org.freedesktop.NetworkManager']
        .propertiesChangedStreamController.stream;
  }

  /// Connects to the NetworkManager D-Bus objects.
  /// Must be called before accessing methods and properties.
  Future<void> connect() async {
    // Already connected
    if (_root != null) {
      return;
    }

    _root = DBusRemoteObject(
      systemBus,
      'org.freedesktop.NetworkManager',
      DBusObjectPath('/org/freedesktop'),
    );

    // Subscribe to changes
    var signals = _root.subscribeObjectManagerSignals();
    _objectManagerSubscription = signals.listen((signal) {
      if (signal is DBusObjectManagerInterfacesAddedSignal) {
        var object = _objects[signal.changedPath];
        if (object != null) {
          object.updateInterfaces(signal.interfacesAndProperties);
        } else {
          _objects[signal.changedPath] = _NetworkManagerObject(
              systemBus, signal.changedPath, signal.interfacesAndProperties);
        }
      } else if (signal is DBusObjectManagerInterfacesRemovedSignal) {
        var object = _objects[signal.changedPath];
        if (object != null) {
          object.removeInterfaces(signal.interfaces);
        }
      } else if (signal is DBusPropertiesChangedSignal) {
        var object = _objects[signal.path];
        if (object != null) {
          object.updateProperties(
              signal.propertiesInterface, signal.changedProperties);
        }
      }
    });

    // Find all the objects exported.
    var objects = await _root.getManagedObjects();
    objects.forEach((objectPath, interfacesAndProperties) {
      _objects[objectPath] =
          _NetworkManagerObject(systemBus, objectPath, interfacesAndProperties);
    });
  }

  /// The list of realized network device.
  /// Realized devices are those which have backing resources (eg from the kernel or a management daemon like ModemManager, teamd, etc).
  List<NetworkManagerDevice> get devices {
    return _getDevices('Devices');
  }

  /// The list of both realized and un-realized network devices.
  /// Un-realized devices are software devices which do not yet have backing resources, but for which backing resources can be created if the device is activated.
  List<NetworkManagerDevice> get allDevices {
    return _getDevices('AllDevices');
  }

  List<NetworkManagerDevice> _getDevices(String propertyName) {
    if (_manager == null) {
      return null;
    }
    var deviceObjectPaths =
        _manager.getObjectPathArrayProperty(managerInterfaceName, propertyName);
    var devices = <NetworkManagerDevice>[];
    for (var objectPath in deviceObjectPaths) {
      var device = _getDevice(objectPath);
      if (device != null) {
        devices.add(device);
      }
    }

    return devices;
  }

  // FIXME: Checkpoints

  /// True if networking is enabled.
  bool get networkingEnabled {
    if (_manager == null) {
      return null;
    }
    return _manager.getBooleanProperty(
      managerInterfaceName,
      'NetworkingEnabled',
    );
  }

  /// True if wireless network is enabled.
  bool get wirelessEnabled {
    if (_manager == null) {
      return null;
    }
    return _manager.getBooleanProperty(managerInterfaceName, 'WirelessEnabled');
  }

  /// Sets if wireless network is enabled.
  set wirelessEnabled(bool value) {
    if (_manager != null) {
      _manager.setProperty(
        managerInterfaceName,
        'WirelessEnabled',
        DBusBoolean(value),
      );
    }
  }

  /// True if wireless network is enabled via a hardware switch.
  bool get wirelessHardwareEnabled {
    if (_manager == null) {
      return null;
    }
    return _manager.getBooleanProperty(
        managerInterfaceName, 'WirelessHardwareEnabled');
  }

  /// True if mobile broadband is enabled.
  bool get wwanEnabled {
    if (_manager == null) {
      return null;
    }
    return _manager.getBooleanProperty(managerInterfaceName, 'WwanEnabled');
  }

  /// Sets if mobile broadband is enabled.
  set wwanEnabled(bool value) {
    if (_manager != null) {
      _manager.setProperty(
        managerInterfaceName,
        'WwanEnabled',
        DBusBoolean(value),
      );
    }
  }

  /// True if mobile broadband is enabled via a hardware switch.
  bool get wwanHardwareEnabled {
    if (_manager == null) {
      return null;
    }
    return _manager.getBooleanProperty(
      managerInterfaceName,
      'WwanHardwareEnabled',
    );
  }

  /// Currently active connections.
  List<NetworkManagerActiveConnection> get activeConnections {
    if (_manager == null) {
      return null;
    }
    var connectionObjectPaths = _manager.getObjectPathArrayProperty(
      managerInterfaceName,
      'ActiveConnections',
    );
    var connections = <NetworkManagerActiveConnection>[];
    for (var objectPath in connectionObjectPaths) {
      var connection = _objects[objectPath];
      if (connection != null) {
        connections.add(NetworkManagerActiveConnection(this, connection));
      }
    }

    return connections;
  }

  /// The primary connection being used to access the network.
  NetworkManagerActiveConnection get primaryConnection {
    if (_manager == null) {
      return null;
    }
    var objectPath = _manager.getObjectPathProperty(
        managerInterfaceName, 'PrimaryConnection');
    var connection = _objects[objectPath];
    if (connection == null) {
      return null;
    }

    return NetworkManagerActiveConnection(this, connection);
  }

  /// The type of connection being used to access the network.
  String get primaryConnectionType {
    if (_manager == null) {
      return null;
    }
    return _manager.getStringProperty(
      managerInterfaceName,
      'PrimaryConnectionType',
    );
  }

  /// True if the primary connection has traffic limitations.
  NetworkManagerMetered get metered {
    if (_manager == null) {
      return null;
    }
    return NetworkManagerMetered
        .values[_manager.getUint32Property(managerInterfaceName, 'Metered')];
  }

  // FIXME: ActivatingConnection

  /// True is NetworkManager is still starting up.
  bool get startup {
    if (_manager == null) {
      return null;
    }
    return _manager.getBooleanProperty(managerInterfaceName, 'Startup');
  }

  /// The version of NetworkManager running.
  String get version {
    if (_manager == null) {
      return null;
    }
    return _manager.getStringProperty(managerInterfaceName, 'Version');
  }

  // FIXME: Capabilities

  /// The result of the last connectivity check.
  NetworkManagerConnectivityState get connectivity {
    var value =
        _manager.getUint32Property(managerInterfaceName, 'Connectivity');
    if (value == 1) {
      return NetworkManagerConnectivityState.none;
    } else if (value == 2) {
      return NetworkManagerConnectivityState.portal;
    } else if (value == 3) {
      return NetworkManagerConnectivityState.limited;
    } else if (value == 4) {
      return NetworkManagerConnectivityState.full;
    } else {
      return NetworkManagerConnectivityState.unknown;
    }
  }

  /// True if connectivity checking is available.
  bool get connectivityCheckAvailable {
    return _manager.getBooleanProperty(
      managerInterfaceName,
      'ConnectivityCheckAvailable',
    );
  }

  /// True if connectivity checking is enabled.
  bool get connectivityCheckEnabled {
    return _manager.getBooleanProperty(
      managerInterfaceName,
      'ConnectivityCheckEnabled',
    );
  }

  /// Sets if connectivity checking is enabled.
  set connectivityCheckEnabled(bool value) => _manager.setProperty(
        managerInterfaceName,
        'ConnectivityCheckEnabled',
        DBusBoolean(value),
      );

  /// URI used for connectivity checking.
  String get connectivityCheckUri {
    return _manager.getStringProperty(
      managerInterfaceName,
      'ConnectivityCheckUri',
    );
  }

  // FIXME: GlobalDnsConfiguration

  _NetworkManagerObject get _manager =>
      _objects[DBusObjectPath('/org/freedesktop/NetworkManager')];

  /// Gets the settings object.
  NetworkManagerSettings get settings {
    var object =
        _objects[DBusObjectPath('/org/freedesktop/NetworkManager/Settings')];
    if (object == null) {
      return null;
    }
    return NetworkManagerSettings(this, object);
  }

  /// Gets the DNS manager object.
  NetworkManagerDnsManager get dnsManager {
    var object =
        _objects[DBusObjectPath('/org/freedesktop/NetworkManager/DnsManager')];
    if (object == null) {
      return null;
    }
    return NetworkManagerDnsManager(object);
  }

  /// Terminates all active connections. If a client remains unclosed, the Dart process may not terminate.
  void close() {
    if (_objectManagerSubscription != null) {
      _objectManagerSubscription.cancel();
      _objectManagerSubscription = null;
    }
  }

  NetworkManagerDevice _getDevice(DBusObjectPath objectPath) {
    if (objectPath == null) {
      return null;
    }
    var config = _objects[objectPath];
    if (config == null) {
      return null;
    }
    return NetworkManagerDevice(this, config);
  }

  NetworkManagerSettingsConnection _getConnection(DBusObjectPath objectPath) {
    if (objectPath == null) {
      return null;
    }
    var config = _objects[objectPath];
    if (config == null) {
      return null;
    }
    return NetworkManagerSettingsConnection(config);
  }

  NetworkManagerActiveConnection _getActiveConnection(
      DBusObjectPath objectPath) {
    if (objectPath == null) {
      return null;
    }
    var config = _objects[objectPath];
    if (config == null) {
      return null;
    }
    return NetworkManagerActiveConnection(this, config);
  }

  NetworkManagerIP4Config _getIP4Config(DBusObjectPath objectPath) {
    if (objectPath == null) {
      return null;
    }
    var config = _objects[objectPath];
    if (config == null) {
      return null;
    }
    return NetworkManagerIP4Config(config);
  }

  NetworkManagerDHCP4Config _getDHCP4Config(DBusObjectPath objectPath) {
    if (objectPath == null) {
      return null;
    }
    var config = _objects[objectPath];
    if (config == null) {
      return null;
    }
    return NetworkManagerDHCP4Config(config);
  }

  NetworkManagerIP6Config _getIP6Config(DBusObjectPath objectPath) {
    if (objectPath == null) {
      return null;
    }
    var config = _objects[objectPath];
    if (config == null) {
      return null;
    }
    return NetworkManagerIP6Config(config);
  }

  NetworkManagerDHCP6Config _getDHCP6Config(DBusObjectPath objectPath) {
    if (objectPath == null) {
      return null;
    }
    var config = _objects[objectPath];
    if (config == null) {
      return null;
    }
    return NetworkManagerDHCP6Config(config);
  }

  NetworkManagerAccessPoint _getAccessPoint(DBusObjectPath objectPath) {
    if (objectPath == null) {
      return null;
    }
    var config = _objects[objectPath];
    if (config == null) {
      return null;
    }
    return NetworkManagerAccessPoint(config);
  }
}
