import 'dart:io';

import 'package:dbus/dbus.dart';
import 'package:nm/nm.dart';
import 'package:test/test.dart';

class MockNetworkManagerObject extends DBusObject {
  MockNetworkManagerObject(DBusObjectPath path) : super(path);
}

class MockNetworkManagerManager extends MockNetworkManagerObject {
  final MockNetworkManagerServer server;

  MockNetworkManagerManager(this.server)
      : super(DBusObjectPath('/org/freedesktop/NetworkManager'));

  @override
  Map<String, Map<String, DBusValue>> get interfacesAndProperties => {
        'org.freedesktop.NetworkManager': {
          'ActivatingConnection':
              server.activatingConnection?.path ?? DBusObjectPath('/'),
          'ActiveConnections': DBusArray(DBusSignature('o'),
              server.activeConnections.map((device) => device.path)),
          'AllDevices': DBusArray(DBusSignature('o'),
              server.allDevices.map((device) => device.path)),
          'Capabilities': DBusArray(DBusSignature('u'),
              server.capabilities.map((cap) => DBusUint32(cap))),
          'Checkpoints': DBusArray(DBusSignature('o'), []), // FIXME
          'Connectivity': DBusUint32(server.connectivity),
          'ConnectivityCheckAvailable':
              DBusBoolean(server.connectivityCheckAvailable),
          'ConnectivityCheckEnabled':
              DBusBoolean(server.connectivityCheckEnabled),
          'ConnectivityCheckUri': DBusString(server.connectivityCheckUri),
          'Devices': DBusArray(
              DBusSignature('o'), server.devices.map((device) => device.path)),
          'Metered': DBusUint32(server.metered),
          'NetworkingEnabled': DBusBoolean(server.networkingEnabled),
          'PrimaryConnection':
              server.primaryConnection?.path ?? DBusObjectPath('/'),
          'PrimaryConnectionType':
              DBusString(server.primaryConnection?.type ?? ''),
          'Startup': DBusBoolean(server.startup),
          'State': DBusUint32(server.state),
          'Version': DBusString(server.version),
          'WimaxEnabled': DBusBoolean(server.wimaxEnabled),
          'WimaxHardwareEnabled': DBusBoolean(server.wimaxHardwareEnabled),
          'WirelessEnabled': DBusBoolean(server.wirelessEnabled),
          'WirelessHardwareEnabled':
              DBusBoolean(server.wirelessHardwareEnabled),
          'WwanEnabled': DBusBoolean(server.wwanEnabled),
          'WwanHardwareEnabled': DBusBoolean(server.wwanHardwareEnabled)
        }
      };

  @override
  Future<DBusMethodResponse> handleMethodCall(DBusMethodCall methodCall) async {
    if (methodCall.interface != 'org.freedesktop.NetworkManager') {
      return DBusMethodErrorResponse.unknownInterface();
    }

    switch (methodCall.name) {
      case 'ActivateConnection':
        return DBusMethodSuccessResponse([DBusObjectPath('/')]);
      case 'CheckConnectivity':
        return DBusMethodSuccessResponse([DBusUint32(server.connectivity)]);
      case 'DeactivateConnection':
        return DBusMethodSuccessResponse([]);
      case 'Enable':
        return DBusMethodSuccessResponse([]);
      case 'GetAllDevices':
        return DBusMethodSuccessResponse([DBusArray(DBusSignature('o'), [])]);
      case 'GetDeviceByIpIface':
        return DBusMethodSuccessResponse([DBusObjectPath('/')]);
      case 'GetDevices':
        return DBusMethodSuccessResponse([DBusArray(DBusSignature('o'), [])]);
      case 'GetPermissions':
        return DBusMethodSuccessResponse(
            [DBusDict(DBusSignature('s'), DBusSignature('s'), {})]);
      case 'Reload':
        return DBusMethodSuccessResponse([]);
      case 'SetLogging':
        return DBusMethodSuccessResponse([]);
      case 'Sleep':
        return DBusMethodSuccessResponse([]);
      default:
        return DBusMethodErrorResponse.unknownMethod();
    }
  }
}

class MockNetworkManagerSettings extends MockNetworkManagerObject {
  final MockNetworkManagerServer server;

  MockNetworkManagerSettings(this.server)
      : super(DBusObjectPath('/org/freedesktop/NetworkManager/Settings'));

  @override
  Map<String, Map<String, DBusValue>> get interfacesAndProperties => {
        'org.freedesktop.NetworkManager.Settings': {
          'CanModify': DBusBoolean(server.settingsCanModify),
          'Connections': DBusArray(DBusSignature('o'),
              server.connectionSettings.map((setting) => setting.path)),
          'Hostname': DBusString(server.hostname)
        }
      };

  @override
  Future<DBusMethodResponse> handleMethodCall(DBusMethodCall methodCall) async {
    if (methodCall.interface != 'org.freedesktop.NetworkManager.Settings') {
      return DBusMethodErrorResponse.unknownInterface();
    }

    switch (methodCall.name) {
      case 'AddConnection':
        var connection = await server.addConnectionSettings();
        return DBusMethodSuccessResponse([connection.path]);
      case 'AddConnectionUnsaved':
        var connection = await server.addConnectionSettings(unsaved: true);
        return DBusMethodSuccessResponse([connection.path]);
      case 'ListConnections':
        return DBusMethodSuccessResponse([
          DBusArray(DBusSignature('o'),
              server.connectionSettings.map((setting) => setting.path))
        ]);
      default:
        return DBusMethodErrorResponse.unknownMethod();
    }
  }
}

class MockNetworkManagerConnectionSettings extends MockNetworkManagerObject {
  final String filename;
  final int flags;
  final bool unsaved;

  var deleted = false;
  var saved = false;
  Map<String, Map<String, DBusValue>> secrets;
  Map<String, Map<String, DBusValue>> settings;

  MockNetworkManagerConnectionSettings(int id,
      {this.filename = '',
      this.flags = 0,
      Map<String, Map<String, DBusValue>>? secrets,
      Map<String, Map<String, DBusValue>>? settings,
      this.unsaved = false})
      : secrets = secrets ?? <String, Map<String, DBusValue>>{},
        settings = settings ?? <String, Map<String, DBusValue>>{},
        super(DBusObjectPath('/org/freedesktop/NetworkManager/Settings/$id'));

  @override
  Map<String, Map<String, DBusValue>> get interfacesAndProperties => {
        'org.freedesktop.NetworkManager.Settings.Connection': {
          'Filename': DBusString(filename),
          'Flags': DBusUint32(flags),
          'Unsaved': DBusBoolean(unsaved)
        }
      };

  @override
  Future<DBusMethodResponse> handleMethodCall(DBusMethodCall methodCall) async {
    if (methodCall.interface !=
        'org.freedesktop.NetworkManager.Settings.Connection') {
      return DBusMethodErrorResponse.unknownInterface();
    }

    switch (methodCall.name) {
      case 'ClearSecrets':
        secrets = {};
        return DBusMethodSuccessResponse([]);
      case 'Delete':
        deleted = true;
        return DBusMethodSuccessResponse([]);
      case 'GetSecrets':
        //FIXME var settingName = (methodCall.values[0] as DBusString).value;
        return DBusMethodSuccessResponse([
          DBusDict(
              DBusSignature('s'),
              DBusSignature('a{sv}'),
              secrets.map((group, properties) => MapEntry(
                  DBusString(group),
                  DBusDict(
                      DBusSignature('s'),
                      DBusSignature('v'),
                      properties.map((key, value) =>
                          MapEntry(DBusString(key), DBusVariant(value)))))))
        ]);
      case 'GetSettings':
        return DBusMethodSuccessResponse([
          DBusDict(
              DBusSignature('s'),
              DBusSignature('a{sv}'),
              settings.map((group, properties) => MapEntry(
                  DBusString(group),
                  DBusDict(
                      DBusSignature('s'),
                      DBusSignature('v'),
                      properties.map((key, value) =>
                          MapEntry(DBusString(key), DBusVariant(value)))))))
        ]);
      case 'Save':
        saved = true;
        return DBusMethodSuccessResponse([]);
      case 'Update':
        settings = (methodCall.values[0] as DBusDict).children.map(
            (group, properties) => MapEntry(
                (group as DBusString).value,
                (properties as DBusDict).children.map((key, value) => MapEntry(
                    (key as DBusString).value, (value as DBusVariant).value))));
        saved = true;
        return DBusMethodSuccessResponse([]);
      case 'UpdateUnsaved':
        settings = (methodCall.values[0] as DBusDict).children.map(
            (group, properties) => MapEntry(
                (group as DBusString).value,
                (properties as DBusDict).children.map((key, value) => MapEntry(
                    (key as DBusString).value, (value as DBusVariant).value))));
        return DBusMethodSuccessResponse([]);
      default:
        return DBusMethodErrorResponse.unknownMethod();
    }
  }
}

class MockNetworkManagerActiveConnection extends MockNetworkManagerObject {
  final bool default4;
  final bool default6;
  final List<MockNetworkManagerDevice> devices;
  final MockNetworkManagerDHCP4Config? dhcp4Config;
  final MockNetworkManagerDHCP6Config? dhcp6Config;
  final String id;
  final MockNetworkManagerIP4Config? ip4Config;
  final MockNetworkManagerIP6Config? ip6Config;
  final int state;
  final int stateFlags;
  final String type;
  final String uuid;
  final bool vpn;

  MockNetworkManagerActiveConnection(int number,
      {this.default4 = false,
      this.default6 = false,
      this.devices = const [],
      this.dhcp4Config,
      this.dhcp6Config,
      this.id = '',
      this.ip4Config,
      this.ip6Config,
      this.state = 0,
      this.stateFlags = 0,
      this.type = '',
      this.uuid = '',
      this.vpn = false})
      : super(DBusObjectPath(
            '/org/freedesktop/NetworkManager/ActiveConnection/$number'));

  @override
  Map<String, Map<String, DBusValue>> get interfacesAndProperties => {
        'org.freedesktop.NetworkManager.Connection.Active': {
          'Connection': DBusObjectPath('/'), // FIXME
          'Devices': DBusArray(
              DBusSignature('o'), devices.map((device) => device.path)),
          'Default': DBusBoolean(default4),
          'Default6': DBusBoolean(default6),
          'Dhcp4Config': dhcp4Config?.path ?? DBusObjectPath('/'),
          'Dhcp6Config': dhcp6Config?.path ?? DBusObjectPath('/'),
          'Id': DBusString(id),
          'Ip4Config': ip4Config?.path ?? DBusObjectPath('/'),
          'Ip6Config': ip6Config?.path ?? DBusObjectPath('/'),
          'Master': DBusObjectPath('/'), // FIXME
          'SpecificObject': DBusObjectPath('/'), // FIXME
          'State': DBusUint32(state),
          'StateFlags': DBusUint32(stateFlags),
          'Type': DBusString(type),
          'Uuid': DBusString(uuid),
          'Vpn': DBusBoolean(vpn),
        }
      };
}

class MockNetworkManagerDevice extends MockNetworkManagerObject {
  final bool autoconnect;
  final int capabilities;
  final int deviceType;
  final MockNetworkManagerDHCP4Config? dhcp4Config;
  final MockNetworkManagerDHCP6Config? dhcp6Config;
  final String driver;
  final String driverVersion;
  final bool firmwareMissing;
  final String firmwareVersion;
  final String hwAddress;
  final String interface;
  final int interfaceFlags;
  final MockNetworkManagerIP4Config? ip4Config;
  final int ip4Connectivity;
  final MockNetworkManagerIP6Config? ip6Config;
  final int ip6Connectivity;
  final String ipInterface;
  final bool managed;
  final int metered;
  final int mtu;
  final bool nmPluginMissing;
  final String path_;
  final String physicalPortId;
  final bool real;
  final int state;
  final String udi;

  final bool hasGeneric;
  final String typeDescription;

  final bool hasWireless;
  final List<MockNetworkManagerAccessPoint> accessPoints;
  final MockNetworkManagerAccessPoint? activeAccessPoint;
  final int bitrate;
  final int lastScan;
  final int wirelessMode;
  final String permHwAddress;
  final int wirelessCapabilities;

  final bool hasStatistics;
  int refreshRateMs;
  final int rxBytes;
  final int txBytes;

  bool disconnected = false;
  bool deleted = false;

  MockNetworkManagerDevice(int id,
      {this.autoconnect = false,
      this.capabilities = 0,
      this.deviceType = 0,
      this.dhcp4Config,
      this.dhcp6Config,
      this.driver = '',
      this.driverVersion = '',
      this.firmwareMissing = false,
      this.firmwareVersion = '',
      this.hwAddress = '',
      this.interface = '',
      this.interfaceFlags = 0,
      this.ip4Config,
      this.ip4Connectivity = 0,
      this.ip6Config,
      this.ip6Connectivity = 0,
      this.ipInterface = '',
      this.managed = false,
      this.metered = 0,
      this.mtu = 0,
      this.nmPluginMissing = false,
      this.path_ = '',
      this.physicalPortId = '',
      this.real = true,
      this.state = 0,
      this.udi = '',
      this.hasGeneric = false,
      this.typeDescription = '',
      this.hasWireless = false,
      this.accessPoints = const [],
      this.activeAccessPoint,
      this.bitrate = 0,
      this.lastScan = 0,
      this.wirelessMode = 0,
      this.permHwAddress = '',
      this.wirelessCapabilities = 0,
      this.hasStatistics = false,
      this.refreshRateMs = 0,
      this.rxBytes = 0,
      this.txBytes = 0})
      : super(DBusObjectPath('/org/freedesktop/NetworkManager/Devices/$id'));

  @override
  Map<String, Map<String, DBusValue>> get interfacesAndProperties {
    var interfacesAndProperties_ = {
      'org.freedesktop.NetworkManager.Device': {
        'Autoconnect': DBusBoolean(autoconnect),
        'Capabilities': DBusUint32(capabilities),
        'DeviceType': DBusUint32(deviceType),
        'Dhcp4Config': dhcp4Config?.path ?? DBusObjectPath('/'),
        'Dhcp6Config': dhcp6Config?.path ?? DBusObjectPath('/'),
        'Driver': DBusString(driver),
        'DriverVersion': DBusString(driverVersion),
        'FirmwareMissing': DBusBoolean(firmwareMissing),
        'FirmwareVersion': DBusString(firmwareVersion),
        'HwAddress': DBusString(hwAddress),
        'Interface': DBusString(interface),
        'InterfaceFlags': DBusUint32(interfaceFlags),
        'Ip4Config': ip4Config?.path ?? DBusObjectPath('/'),
        'Ip4Connectivity': DBusUint32(ip4Connectivity),
        'Ip6Config': ip6Config?.path ?? DBusObjectPath('/'),
        'Ip6Connectivity': DBusUint32(ip6Connectivity),
        'IpInterface': DBusString(ipInterface),
        'Managed': DBusBoolean(managed),
        'Metered': DBusUint32(metered),
        'Mtu': DBusUint32(mtu),
        'NmPluginMissing': DBusBoolean(nmPluginMissing),
        'Path': DBusString(path_),
        'PhysicalPortId': DBusString(physicalPortId),
        'Real': DBusBoolean(real),
        'State': DBusUint32(state),
        'Udi': DBusString(udi)
      }
    };
    if (hasGeneric) {
      interfacesAndProperties_[
          'org.freedesktop.NetworkManager.Device.Generic'] = {
        'HwAddress': DBusString(hwAddress),
        'TypeDescription': DBusString(typeDescription)
      };
    }
    if (hasWireless) {
      interfacesAndProperties_[
          'org.freedesktop.NetworkManager.Device.Wireless'] = {
        'AccessPoints': DBusArray(DBusSignature('o'),
            accessPoints.map((accessPoint) => accessPoint.path)),
        'ActiveAccessPoint': activeAccessPoint?.path ?? DBusObjectPath('/'),
        'Bitrate': DBusUint32(bitrate),
        'LastScan': DBusInt64(lastScan),
        'Mode': DBusUint32(wirelessMode),
        'PermHwAddress': DBusString(permHwAddress),
        'WirelessCapabilities': DBusUint32(wirelessCapabilities)
      };
    }
    if (hasStatistics) {
      interfacesAndProperties_[
          'org.freedesktop.NetworkManager.Device.Statistics'] = {
        'RefreshRateMs': DBusUint32(refreshRateMs),
        'RxBytes': DBusUint64(rxBytes),
        'TxBytes': DBusUint64(txBytes)
      };
    }

    return interfacesAndProperties_;
  }

  @override
  Future<DBusMethodResponse> setProperty(
      String interface, String name, DBusValue value) async {
    if (interface == 'org.freedesktop.NetworkManager.Device') {
      return DBusMethodErrorResponse.propertyReadOnly();
    } else if (hasGeneric &&
        interface == 'org.freedesktop.NetworkManager.Device.Generic') {
      return DBusMethodErrorResponse.propertyReadOnly();
    } else if (hasWireless &&
        interface == 'org.freedesktop.NetworkManager.Device.Wireless') {
      return DBusMethodErrorResponse.propertyReadOnly();
    } else if (hasStatistics &&
        interface == 'org.freedesktop.NetworkManager.Device.Statistics') {
      if (name == 'RefreshRateMs') {
        refreshRateMs = (value as DBusUint32).value;
        return DBusMethodSuccessResponse();
      } else {
        return DBusMethodErrorResponse.propertyReadOnly();
      }
    } else {
      return DBusMethodErrorResponse.unknownInterface();
    }
  }

  @override
  Future<DBusMethodResponse> handleMethodCall(DBusMethodCall methodCall) async {
    if (methodCall.interface != 'org.freedesktop.NetworkManager.Device') {
      return DBusMethodErrorResponse.unknownInterface();
    }

    switch (methodCall.name) {
      case 'Disconnect':
        disconnected = true;
        return DBusMethodSuccessResponse([]);
      case 'Delete':
        deleted = true;
        return DBusMethodSuccessResponse([]);
      default:
        return DBusMethodErrorResponse.unknownMethod();
    }
  }
}

class MockNetworkManagerAccessPoint extends MockNetworkManagerObject {
  final int flags;
  final int frequency;
  final String hwAddress;
  final int lastSeen;
  final int maxBitrate;
  final int mode;
  final int rsnFlags;
  final List<int> ssid;
  final int strength;
  final int wpaFlags;

  MockNetworkManagerAccessPoint(int id,
      {this.flags = 0,
      this.frequency = 0,
      this.hwAddress = '',
      this.lastSeen = 0,
      this.maxBitrate = 0,
      this.mode = 0,
      this.rsnFlags = 0,
      this.ssid = const [],
      this.strength = 0,
      this.wpaFlags = 0})
      : super(
            DBusObjectPath('/org/freedesktop/NetworkManager/AccessPoints/$id'));

  @override
  Map<String, Map<String, DBusValue>> get interfacesAndProperties => {
        'org.freedesktop.NetworkManager.AccessPoint': {
          'Flags': DBusUint32(flags),
          'Frequency': DBusUint32(frequency),
          'HwAddress': DBusString(hwAddress),
          'LastSeen': DBusInt32(lastSeen),
          'MaxBitrate': DBusUint32(maxBitrate),
          'Mode': DBusUint32(mode),
          'RsnFlags': DBusUint32(rsnFlags),
          'Ssid': DBusArray(DBusSignature('y'), ssid.map((v) => DBusByte(v))),
          'Strength': DBusByte(strength),
          'WpaFlags': DBusUint32(wpaFlags)
        }
      };
}

class MockNetworkManagerIP4Config extends MockNetworkManagerObject {
  final List<Map<String, DBusValue>> addressData;
  final List<String> dnsOptions;
  final int dnsPriority;
  final List<String> domains;
  final String gateway;
  final List<Map<String, DBusValue>> nameserverData;
  final List<Map<String, DBusValue>> routeData;
  final List<String> searches;
  final List<String> winsServerData;

  MockNetworkManagerIP4Config(int id,
      {this.addressData = const [],
      this.dnsOptions = const [],
      this.dnsPriority = 0,
      this.domains = const [],
      this.gateway = '',
      this.nameserverData = const [],
      this.routeData = const [],
      this.searches = const [],
      this.winsServerData = const []})
      : super(DBusObjectPath('/org/freedesktop/NetworkManager/IP4Config/$id'));

  @override
  Map<String, Map<String, DBusValue>> get interfacesAndProperties => {
        'org.freedesktop.NetworkManager.IP4Config': {
          'AddressData': DBusArray(
              DBusSignature('a{sv}'),
              addressData.map((data) => DBusDict(
                  DBusSignature('s'),
                  DBusSignature('v'),
                  data.map((key, value) =>
                      MapEntry(DBusString(key), DBusVariant(value)))))),
          'DnsOptions': DBusArray(DBusSignature('s'),
              dnsOptions.map((option) => DBusString(option))),
          'DnsPriority': DBusInt32(dnsPriority),
          'Domains': DBusArray(
              DBusSignature('s'), domains.map((domain) => DBusString(domain))),
          'Gateway': DBusString(gateway),
          'NameserverData': DBusArray(
              DBusSignature('a{sv}'),
              nameserverData.map((data) => DBusDict(
                  DBusSignature('s'),
                  DBusSignature('v'),
                  data.map((key, value) =>
                      MapEntry(DBusString(key), DBusVariant(value)))))),
          'RouteData': DBusArray(
              DBusSignature('a{sv}'),
              routeData.map((data) => DBusDict(
                  DBusSignature('s'),
                  DBusSignature('v'),
                  data.map((key, value) =>
                      MapEntry(DBusString(key), DBusVariant(value)))))),
          'Searches': DBusArray(
              DBusSignature('s'), searches.map((search) => DBusString(search))),
          'WinsServerData': DBusArray(DBusSignature('s'),
              winsServerData.map((server) => DBusString(server)))
        }
      };
}

class MockNetworkManagerIP6Config extends MockNetworkManagerObject {
  final List<Map<String, DBusValue>> addressData;
  final List<String> dnsOptions;
  final int dnsPriority;
  final List<String> domains;
  final String gateway;
  final List<Map<String, DBusValue>> nameserverData;
  final List<Map<String, DBusValue>> routeData;
  final List<String> searches;

  MockNetworkManagerIP6Config(int id,
      {this.addressData = const [],
      this.dnsOptions = const [],
      this.dnsPriority = 0,
      this.domains = const [],
      this.gateway = '',
      this.nameserverData = const [],
      this.routeData = const [],
      this.searches = const []})
      : super(DBusObjectPath('/org/freedesktop/NetworkManager/IP6Config/$id'));

  @override
  Map<String, Map<String, DBusValue>> get interfacesAndProperties => {
        'org.freedesktop.NetworkManager.IP6Config': {
          'AddressData': DBusArray(
              DBusSignature('a{sv}'),
              addressData.map((data) => DBusDict(
                  DBusSignature('s'),
                  DBusSignature('v'),
                  data.map((key, value) =>
                      MapEntry(DBusString(key), DBusVariant(value)))))),
          'DnsOptions': DBusArray(DBusSignature('s'),
              dnsOptions.map((option) => DBusString(option))),
          'DnsPriority': DBusInt32(dnsPriority),
          'Domains': DBusArray(
              DBusSignature('s'), domains.map((domain) => DBusString(domain))),
          'Gateway': DBusString(gateway),
          'NameserverData': DBusArray(
              DBusSignature('a{sv}'),
              nameserverData.map((data) => DBusDict(
                  DBusSignature('s'),
                  DBusSignature('v'),
                  data.map((key, value) =>
                      MapEntry(DBusString(key), DBusVariant(value)))))),
          'RouteData': DBusArray(
              DBusSignature('a{sv}'),
              routeData.map((data) => DBusDict(
                  DBusSignature('s'),
                  DBusSignature('v'),
                  data.map((key, value) =>
                      MapEntry(DBusString(key), DBusVariant(value)))))),
          'Searches': DBusArray(
              DBusSignature('s'), searches.map((search) => DBusString(search)))
        }
      };
}

class MockNetworkManagerDHCP4Config extends MockNetworkManagerObject {
  final Map<String, DBusValue> options;

  MockNetworkManagerDHCP4Config(int id, {this.options = const {}})
      : super(
            DBusObjectPath('/org/freedesktop/NetworkManager/DHCP4Config/$id'));

  @override
  Map<String, Map<String, DBusValue>> get interfacesAndProperties => {
        'org.freedesktop.NetworkManager.DHCP4Config': {
          'Options': DBusDict(
              DBusSignature('s'),
              DBusSignature('v'),
              options.map((key, value) =>
                  MapEntry(DBusString(key), DBusVariant(value))))
        }
      };
}

class MockNetworkManagerDHCP6Config extends MockNetworkManagerObject {
  final Map<String, DBusValue> options;

  MockNetworkManagerDHCP6Config(int id, {this.options = const {}})
      : super(
            DBusObjectPath('/org/freedesktop/NetworkManager/DHCP6Config/$id'));

  @override
  Map<String, Map<String, DBusValue>> get interfacesAndProperties => {
        'org.freedesktop.NetworkManager.DHCP6Config': {
          'Options': DBusDict(
              DBusSignature('s'),
              DBusSignature('v'),
              options.map((key, value) =>
                  MapEntry(DBusString(key), DBusVariant(value))))
        }
      };
}

class MockNetworkManagerServer extends DBusClient {
  final List<int> capabilities;
  final int connectivity;
  final bool connectivityCheckAvailable;
  final bool connectivityCheckEnabled;
  final String connectivityCheckUri;
  final String hostname;
  final int metered;
  final bool networkingEnabled;
  final bool settingsCanModify;
  final bool startup;
  final int state;
  final String version;
  final bool wimaxEnabled;
  final bool wimaxHardwareEnabled;
  final bool wirelessEnabled;
  final bool wirelessHardwareEnabled;
  final bool wwanEnabled;
  final bool wwanHardwareEnabled;

  final DBusObject _root;
  late final MockNetworkManagerManager _manager;
  late final MockNetworkManagerSettings _settings;
  var _nextIp4ConfigId = 1;
  var _nextIp6ConfigId = 1;
  var _nextDhcp4ConfigId = 1;
  var _nextDhcp6ConfigId = 1;
  var _nextAccessPointId = 1;
  var _nextDeviceId = 1;
  var _nextActiveConnectionId = 1;
  var _nextSettingsId = 1;

  final allDevices = <MockNetworkManagerDevice>[];
  final devices = <MockNetworkManagerDevice>[];
  MockNetworkManagerActiveConnection? activatingConnection;
  final activeConnections = <MockNetworkManagerActiveConnection>[];
  MockNetworkManagerActiveConnection? primaryConnection;
  final connectionSettings = <MockNetworkManagerConnectionSettings>[];

  MockNetworkManagerServer(DBusAddress clientAddress,
      {this.capabilities = const [],
      this.connectivity = 0,
      this.connectivityCheckAvailable = false,
      this.connectivityCheckEnabled = false,
      this.connectivityCheckUri = '',
      this.hostname = '',
      this.metered = 0,
      this.networkingEnabled = false,
      this.settingsCanModify = false,
      this.startup = false,
      this.state = 0,
      this.version = '',
      this.wimaxEnabled = false,
      this.wimaxHardwareEnabled = false,
      this.wirelessEnabled = false,
      this.wirelessHardwareEnabled = false,
      this.wwanEnabled = false,
      this.wwanHardwareEnabled = false})
      : _root = DBusObject(DBusObjectPath('/org/freedesktop'),
            isObjectManager: true),
        super(clientAddress) {
    _manager = MockNetworkManagerManager(this);
    _settings = MockNetworkManagerSettings(this);
  }

  Future<void> start() async {
    await requestName('org.freedesktop.NetworkManager');
    await registerObject(_root);
    await registerObject(_manager);
    await registerObject(_settings);
  }

  Future<MockNetworkManagerIP4Config> addIp4Config({
    List<Map<String, DBusValue>> addressData = const [],
    List<String> dnsOptions = const [],
    int dnsPriority = 0,
    List<String> domains = const [],
    String gateway = '',
    List<Map<String, DBusValue>> nameserverData = const [],
    List<Map<String, DBusValue>> routeData = const [],
    List<String> searches = const [],
    List<String> winsServerData = const [],
  }) async {
    var config = MockNetworkManagerIP4Config(_nextIp4ConfigId,
        addressData: addressData,
        dnsOptions: dnsOptions,
        dnsPriority: dnsPriority,
        domains: domains,
        gateway: gateway,
        nameserverData: nameserverData,
        routeData: routeData,
        searches: searches,
        winsServerData: winsServerData);
    _nextIp4ConfigId++;
    await registerObject(config);
    return config;
  }

  Future<MockNetworkManagerIP6Config> addIp6Config(
      {List<Map<String, DBusValue>> addressData = const [],
      List<String> dnsOptions = const [],
      int dnsPriority = 0,
      List<String> domains = const [],
      String gateway = '',
      List<Map<String, DBusValue>> nameserverData = const [],
      List<Map<String, DBusValue>> routeData = const [],
      List<String> searches = const []}) async {
    var config = MockNetworkManagerIP6Config(_nextIp6ConfigId,
        addressData: addressData,
        dnsOptions: dnsOptions,
        dnsPriority: dnsPriority,
        domains: domains,
        gateway: gateway,
        nameserverData: nameserverData,
        routeData: routeData,
        searches: searches);
    _nextIp6ConfigId++;
    await registerObject(config);
    return config;
  }

  Future<MockNetworkManagerDHCP4Config> addDhcp4Config(
      {Map<String, DBusValue> options = const {}}) async {
    var config =
        MockNetworkManagerDHCP4Config(_nextDhcp4ConfigId, options: options);
    _nextDhcp4ConfigId++;
    await registerObject(config);
    return config;
  }

  Future<MockNetworkManagerDHCP6Config> addDhcp6Config(
      {Map<String, DBusValue> options = const {}}) async {
    var config =
        MockNetworkManagerDHCP6Config(_nextDhcp6ConfigId, options: options);
    _nextDhcp6ConfigId++;
    await registerObject(config);
    return config;
  }

  Future<MockNetworkManagerAccessPoint> addAccessPoint(
      {int flags = 0,
      int frequency = 0,
      String hwAddress = '',
      int lastSeen = 0,
      int maxBitrate = 0,
      int mode = 0,
      int rsnFlags = 0,
      List<int> ssid = const [],
      int strength = 0,
      int wpaFlags = 0}) async {
    var accessPoint = MockNetworkManagerAccessPoint(_nextAccessPointId,
        flags: flags,
        frequency: frequency,
        hwAddress: hwAddress,
        lastSeen: lastSeen,
        maxBitrate: maxBitrate,
        mode: mode,
        rsnFlags: rsnFlags,
        ssid: ssid,
        strength: strength,
        wpaFlags: wpaFlags);
    _nextAccessPointId++;
    await registerObject(accessPoint);
    return accessPoint;
  }

  Future<MockNetworkManagerConnectionSettings> addConnectionSettings(
      {String filename = '',
      int flags = 0,
      Map<String, Map<String, DBusValue>>? secrets,
      Map<String, Map<String, DBusValue>>? settings,
      bool unsaved = false}) async {
    var s = MockNetworkManagerConnectionSettings(_nextSettingsId,
        filename: filename,
        flags: flags,
        secrets: secrets,
        settings: settings,
        unsaved: unsaved);
    _nextSettingsId++;
    await registerObject(s);
    connectionSettings.add(s);
    return s;
  }

  Future<MockNetworkManagerDevice> addDevice(
      {bool autoconnect = false,
      int capabilities = 0,
      int deviceType = 0,
      MockNetworkManagerDHCP4Config? dhcp4Config,
      MockNetworkManagerDHCP6Config? dhcp6Config,
      String driver = '',
      String driverVersion = '',
      String firmwareVersion = '',
      String hwAddress = '',
      String interface = '',
      int interfaceFlags = 0,
      MockNetworkManagerIP4Config? ip4Config,
      int ip4Connectivity = 0,
      MockNetworkManagerIP6Config? ip6Config,
      int ip6Connectivity = 0,
      String ipInterface = '',
      bool managed = false,
      int metered = 0,
      int mtu = 0,
      bool nmPluginMissing = false,
      String path = '',
      String physicalPortId = '',
      bool real = true,
      int state = 0,
      String udi = '',
      bool hasGeneric = false,
      String typeDescription = '',
      bool hasWireless = false,
      List<MockNetworkManagerAccessPoint> accessPoints = const [],
      MockNetworkManagerAccessPoint? activeAccessPoint,
      int bitrate = 0,
      int lastScan = 0,
      int wirelessMode = 0,
      String permHwAddress = '',
      int wirelessCapabilities = 0,
      bool hasStatistics = false,
      int refreshRateMs = 0,
      int rxBytes = 0,
      int txBytes = 0}) async {
    var device = MockNetworkManagerDevice(_nextDeviceId,
        autoconnect: autoconnect,
        capabilities: capabilities,
        deviceType: deviceType,
        dhcp4Config: dhcp4Config,
        dhcp6Config: dhcp6Config,
        driver: driver,
        driverVersion: driverVersion,
        firmwareVersion: firmwareVersion,
        hwAddress: hwAddress,
        interface: interface,
        interfaceFlags: interfaceFlags,
        ip4Config: ip4Config,
        ip4Connectivity: ip4Connectivity,
        ip6Config: ip6Config,
        ip6Connectivity: ip6Connectivity,
        ipInterface: ipInterface,
        managed: managed,
        metered: metered,
        mtu: mtu,
        nmPluginMissing: nmPluginMissing,
        path_: path,
        physicalPortId: physicalPortId,
        real: real,
        state: state,
        udi: udi,
        hasGeneric: hasGeneric,
        typeDescription: typeDescription,
        hasWireless: hasWireless,
        accessPoints: accessPoints,
        activeAccessPoint: activeAccessPoint,
        bitrate: bitrate,
        lastScan: lastScan,
        wirelessMode: wirelessMode,
        permHwAddress: permHwAddress,
        wirelessCapabilities: wirelessCapabilities,
        hasStatistics: hasStatistics,
        refreshRateMs: refreshRateMs,
        rxBytes: rxBytes,
        txBytes: txBytes);
    _nextDeviceId++;
    await registerObject(device);
    allDevices.add(device);
    devices.add(device);
    return device;
  }

  Future<MockNetworkManagerActiveConnection> addActiveConnection(
      {bool default4 = false,
      bool default6 = false,
      List<MockNetworkManagerDevice> devices = const [],
      MockNetworkManagerDHCP4Config? dhcp4Config,
      MockNetworkManagerDHCP6Config? dhcp6Config,
      String id = '',
      MockNetworkManagerIP4Config? ip4Config,
      MockNetworkManagerIP6Config? ip6Config,
      int state = 0,
      int stateFlags = 0,
      String type = '',
      String uuid = '',
      bool vpn = false}) async {
    var activeConnection = MockNetworkManagerActiveConnection(
        _nextActiveConnectionId,
        default4: default4,
        default6: default6,
        devices: devices,
        dhcp4Config: dhcp4Config,
        dhcp6Config: dhcp6Config,
        id: id,
        ip4Config: ip4Config,
        ip6Config: ip6Config,
        state: state,
        stateFlags: stateFlags,
        type: type,
        uuid: uuid,
        vpn: vpn);
    _nextActiveConnectionId++;
    await registerObject(activeConnection);
    activeConnections.add(activeConnection);
    return activeConnection;
  }
}

void main() {
  test('version', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));

    var nm = MockNetworkManagerServer(clientAddress, version: '1.2.3');
    await nm.start();

    var client = NetworkManagerClient(bus: DBusClient(clientAddress));
    await client.connect();

    expect(client.version, equals('1.2.3'));

    await client.close();
  });

  test('connectivity', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));

    var nm = MockNetworkManagerServer(clientAddress,
        connectivityCheckAvailable: true,
        connectivityCheckEnabled: true,
        connectivityCheckUri: 'http://example.com',
        connectivity: 4);
    await nm.start();

    var client = NetworkManagerClient(bus: DBusClient(clientAddress));
    await client.connect();

    expect(client.connectivityCheckAvailable, isTrue);
    expect(client.connectivityCheckEnabled, isTrue);
    expect(client.connectivityCheckUri, equals('http://example.com'));
    expect(client.connectivity, NetworkManagerConnectivityState.full);

    await client.close();
  });

  test('hostname', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));

    var nm = MockNetworkManagerServer(clientAddress, hostname: 'HOSTNAME');
    await nm.start();

    var client = NetworkManagerClient(bus: DBusClient(clientAddress));
    await client.connect();

    expect(client.settings.hostname, equals('HOSTNAME'));

    await client.close();
  });

  test('no settings', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));

    var nm = MockNetworkManagerServer(clientAddress);
    await nm.start();

    var client = NetworkManagerClient(bus: DBusClient(clientAddress));
    await client.connect();

    expect(client.settings.connections, isEmpty);

    await client.close();
  });

  test('settings', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));

    var nm = MockNetworkManagerServer(clientAddress, settingsCanModify: true);
    await nm.start();
    await nm.addConnectionSettings(
        filename:
            '/etc/NetworkManager/system-connections/Ethernet.nmconnection');
    await nm.addConnectionSettings(
        filename: '/etc/NetworkManager/system-connections/accesspoint1');
    await nm.addConnectionSettings(
        filename: '/etc/NetworkManager/system-connections/accesspoint2',
        unsaved: true,
        flags: 0xf);

    var client = NetworkManagerClient(bus: DBusClient(clientAddress));
    await client.connect();

    expect(client.settings.canModify, isTrue);
    expect(client.settings.connections, hasLength(3));
    expect(client.settings.connections[0].filename,
        equals('/etc/NetworkManager/system-connections/Ethernet.nmconnection'));
    expect(client.settings.connections[1].filename,
        equals('/etc/NetworkManager/system-connections/accesspoint1'));
    expect(client.settings.connections[2].filename,
        equals('/etc/NetworkManager/system-connections/accesspoint2'));
    expect(client.settings.connections[2].unsaved, isTrue);
    expect(
        client.settings.connections[2].flags,
        equals({
          NetworkManagerConnectionFlag.unsaved,
          NetworkManagerConnectionFlag.networkManagerGenerated,
          NetworkManagerConnectionFlag.volatile,
          NetworkManagerConnectionFlag.external
        }));

    await client.close();
  });

  test('settings save', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));

    var nm = MockNetworkManagerServer(clientAddress);
    await nm.start();
    var s = await nm.addConnectionSettings();

    var client = NetworkManagerClient(bus: DBusClient(clientAddress));
    await client.connect();

    expect(client.settings.connections, hasLength(1));
    var connection = client.settings.connections[0];
    expect(s.saved, isFalse);
    await connection.save();
    expect(s.saved, isTrue);

    await client.close();
  });

  test('settings delete', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));

    var nm = MockNetworkManagerServer(clientAddress);
    await nm.start();
    var s = await nm.addConnectionSettings();

    var client = NetworkManagerClient(bus: DBusClient(clientAddress));
    await client.connect();

    expect(client.settings.connections, hasLength(1));
    var connection = client.settings.connections[0];
    expect(s.deleted, isFalse);
    await connection.delete();
    expect(s.deleted, isTrue);

    await client.close();
  });

  test('settings get', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));

    var nm = MockNetworkManagerServer(clientAddress);
    await nm.start();
    await nm.addConnectionSettings(settings: {
      'group1': {'setting1a': DBusString('value')},
      'group2': {'setting2a': DBusUint32(42)}
    });

    var client = NetworkManagerClient(bus: DBusClient(clientAddress));
    await client.connect();

    expect(client.settings.connections, hasLength(1));
    var connection = client.settings.connections[0];
    expect(
        await connection.getSettings(),
        equals({
          'group1': {'setting1a': DBusString('value')},
          'group2': {'setting2a': DBusUint32(42)}
        }));

    await client.close();
  });

  test('settings get secrets', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));

    var nm = MockNetworkManagerServer(clientAddress);
    await nm.start();
    await nm.addConnectionSettings(secrets: {
      'group1': {'secret1a': DBusString('value')},
      'group2': {'secret2a': DBusUint32(42)}
    });

    var client = NetworkManagerClient(bus: DBusClient(clientAddress));
    await client.connect();

    expect(client.settings.connections, hasLength(1));
    var connection = client.settings.connections[0];
    expect(
        await connection.getSecrets(),
        equals({
          'group1': {'secret1a': DBusString('value')},
          'group2': {'secret2a': DBusUint32(42)}
        }));

    await client.close();
  });

  test('settings clear secrets', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));

    var nm = MockNetworkManagerServer(clientAddress);
    await nm.start();
    var s = await nm.addConnectionSettings(secrets: {
      'group1': {'secret1a': DBusString('value')},
      'group2': {'secret2a': DBusUint32(42)}
    });

    var client = NetworkManagerClient(bus: DBusClient(clientAddress));
    await client.connect();

    expect(client.settings.connections, hasLength(1));
    var connection = client.settings.connections[0];
    await connection.clearSecrets();
    expect(s.secrets, equals({}));

    await client.close();
  });

  test('settings update', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));

    var nm = MockNetworkManagerServer(clientAddress);
    await nm.start();
    var s = await nm.addConnectionSettings(settings: {
      'group1': {'setting1a': DBusString('value')},
      'group2': {'setting2a': DBusUint32(42)}
    });

    var client = NetworkManagerClient(bus: DBusClient(clientAddress));
    await client.connect();

    expect(client.settings.connections, hasLength(1));
    var connection = client.settings.connections[0];
    expect(s.saved, isFalse);
    await connection.update({
      'group3': {'setting3a': DBusUint32(123)}
    });
    expect(
        s.settings,
        equals({
          'group3': {'setting3a': DBusUint32(123)}
        }));
    expect(s.saved, isTrue);

    await client.close();
  });

  test('settings update unsaved', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));

    var nm = MockNetworkManagerServer(clientAddress);
    await nm.start();
    var s = await nm.addConnectionSettings(settings: {
      'group1': {'setting1a': DBusString('value')},
      'group2': {'setting2a': DBusUint32(42)}
    });

    var client = NetworkManagerClient(bus: DBusClient(clientAddress));
    await client.connect();

    expect(client.settings.connections, hasLength(1));
    var connection = client.settings.connections[0];
    expect(s.saved, isFalse);
    await connection.updateUnsaved({
      'group3': {'setting3a': DBusUint32(123)}
    });
    expect(
        s.settings,
        equals({
          'group3': {'setting3a': DBusUint32(123)}
        }));
    expect(s.saved, isFalse);

    await client.close();
  });

  test('no devices', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));

    var nm = MockNetworkManagerServer(clientAddress);
    await nm.start();

    var client = NetworkManagerClient(bus: DBusClient(clientAddress));
    await client.connect();

    expect(client.devices, isEmpty);

    await client.close();
  });

  test('devices', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));

    var nm = MockNetworkManagerServer(clientAddress);
    await nm.start();
    await nm.addDevice(hwAddress: 'DE:71:CE:00:00:01');
    await nm.addDevice(hwAddress: 'DE:71:CE:00:00:02');
    await nm.addDevice(hwAddress: 'DE:71:CE:00:00:03');

    var client = NetworkManagerClient(bus: DBusClient(clientAddress));
    await client.connect();

    expect(client.devices, hasLength(3));
    expect(client.devices[0].hwAddress, equals('DE:71:CE:00:00:01'));
    expect(client.devices[1].hwAddress, equals('DE:71:CE:00:00:02'));
    expect(client.devices[2].hwAddress, equals('DE:71:CE:00:00:03'));

    await client.close();
  });

  test('device properties', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));

    var nm = MockNetworkManagerServer(clientAddress);
    await nm.start();
    await nm.addDevice(
        autoconnect: true,
        capabilities: 0xf,
        deviceType: 1,
        driver: 'DRIVER',
        driverVersion: 'DRIVER-VERSION',
        firmwareVersion: 'FIRMWARE-VERSION',
        hwAddress: 'DE:71:CE:00:00:01',
        interface: 'INTERFACE',
        interfaceFlags: 0x10003,
        ip4Connectivity: 4,
        ip6Connectivity: 4,
        ipInterface: 'IP-INTERFACE',
        managed: true,
        metered: 1,
        mtu: 1500,
        nmPluginMissing: true,
        path: '/PATH',
        physicalPortId: 'PHYSICAL-PORT-ID',
        real: true,
        state: 100,
        udi: 'UDI');

    var client = NetworkManagerClient(bus: DBusClient(clientAddress));
    await client.connect();

    expect(client.devices, hasLength(1));
    var device = client.devices[0];
    expect(device.autoconnect, isTrue);
    expect(
        device.capabilities,
        equals({
          NetworkManagerDeviceCapability.networkManagerSupported,
          NetworkManagerDeviceCapability.carrierDetect,
          NetworkManagerDeviceCapability.isSoftware,
          NetworkManagerDeviceCapability.singleRootIOVirtualization
        }));
    expect(device.deviceType, equals(NetworkManagerDeviceType.ethernet));
    expect(device.dhcp4Config, isNull);
    expect(device.dhcp6Config, isNull);
    expect(device.driver, equals('DRIVER'));
    expect(device.driverVersion, equals('DRIVER-VERSION'));
    expect(device.firmwareVersion, equals('FIRMWARE-VERSION'));
    expect(device.hwAddress, equals('DE:71:CE:00:00:01'));
    expect(device.interface, equals('INTERFACE'));
    expect(
        device.interfaceFlags,
        equals({
          NetworkManagerDeviceInterfaceFlag.up,
          NetworkManagerDeviceInterfaceFlag.lowerUp,
          NetworkManagerDeviceInterfaceFlag.carrier
        }));
    expect(
        device.ip4Connectivity, equals(NetworkManagerConnectivityState.full));
    expect(
        device.ip6Connectivity, equals(NetworkManagerConnectivityState.full));
    expect(device.ip4Config, isNull);
    expect(device.ip6Config, isNull);
    expect(device.ipInterface, equals('IP-INTERFACE'));
    expect(device.managed, isTrue);
    expect(device.metered, equals(NetworkManagerMetered.yes));
    expect(device.mtu, equals(1500));
    expect(device.nmPluginMissing, isTrue);
    expect(device.path, equals('/PATH'));
    expect(device.physicalPortId, equals('PHYSICAL-PORT-ID'));
    expect(device.real, isTrue);
    expect(device.state, equals(NetworkManagerDeviceState.activated));
    expect(device.udi, equals('UDI'));

    await client.close();
  });

  test('device ip config', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));

    var nm = MockNetworkManagerServer(clientAddress);
    await nm.start();
    var ip4c = await nm.addIp4Config(
        addressData: [
          {'address': DBusString('192.168.0.2'), 'prefix': DBusUint32(16)},
          {'address': DBusString('10.0.0.2'), 'prefix': DBusUint32(8)}
        ],
        dnsOptions: ['option4a', 'option4b'],
        dnsPriority: 42,
        domains: ['domain4a', 'domain4b'],
        gateway: '192.168.0.1',
        nameserverData: [
          {'address': DBusString('8.8.8.8')},
          {'address': DBusString('8.8.4.4')}
        ],
        routeData: [
          {'dest': DBusString('192.168.0.0'), 'prefix': DBusUint32(16)},
          {'dest': DBusString('10.0.0.0'), 'prefix': DBusUint32(8)}
        ],
        searches: ['search4a', 'search4b'],
        winsServerData: ['wins1', 'wins2']);
    var ip6c = await nm.addIp6Config(
        addressData: [
          {
            'address': DBusString('2001:0db8:85a3:0000:0000:8a2e:0370:7334'),
            'prefix': DBusUint32(32)
          },
        ],
        dnsOptions: ['option6a', 'option6b'],
        dnsPriority: 128,
        domains: ['domain6a', 'domain6b'],
        gateway: '2001:0db8:85a3:0000:0000:8a2e:0370:1234',
        nameserverData: [
          {'address': DBusString('2001:4860:4860::8888')},
          {'address': DBusString('2001:4860:4860::8844')}
        ],
        routeData: [
          {
            'dest': DBusString('fe80::'),
            'prefix': DBusUint32(64),
            'metric': DBusUint32(600)
          }
        ],
        searches: ['search6a', 'search6b']);
    await nm.addDevice(ip4Config: ip4c, ip6Config: ip6c);

    var client = NetworkManagerClient(bus: DBusClient(clientAddress));
    await client.connect();

    expect(client.devices, hasLength(1));
    var device = client.devices[0];
    expect(device.ip4Config, isNotNull);
    var ip4Config = device.ip4Config!;
    expect(
        ip4Config.addressData,
        equals([
          {'address': '192.168.0.2', 'prefix': 16},
          {'address': '10.0.0.2', 'prefix': 8}
        ]));
    expect(ip4Config.dnsPriority, equals(42));
    expect(ip4Config.dnsOptions, equals(['option4a', 'option4b']));
    expect(ip4Config.domains, equals(['domain4a', 'domain4b']));
    expect(ip4Config.gateway, equals('192.168.0.1'));
    expect(
        ip4Config.nameserverData,
        equals([
          {'address': '8.8.8.8'},
          {'address': '8.8.4.4'}
        ]));
    expect(
        ip4Config.routeData,
        equals([
          {'dest': '192.168.0.0', 'prefix': 16},
          {'dest': '10.0.0.0', 'prefix': 8}
        ]));
    expect(ip4Config.searches, equals(['search4a', 'search4b']));
    expect(ip4Config.winsServerData, equals(['wins1', 'wins2']));
    expect(device.ip6Config, isNotNull);
    var ip6Config = device.ip6Config!;
    expect(
        ip6Config.addressData,
        equals([
          {'address': '2001:0db8:85a3:0000:0000:8a2e:0370:7334', 'prefix': 32},
        ]));
    expect(ip6Config.dnsPriority, equals(128));
    expect(ip6Config.dnsOptions, equals(['option6a', 'option6b']));
    expect(ip6Config.domains, equals(['domain6a', 'domain6b']));
    expect(
        ip6Config.gateway, equals('2001:0db8:85a3:0000:0000:8a2e:0370:1234'));
    expect(
        ip6Config.nameserverData,
        equals([
          {'address': '2001:4860:4860::8888'},
          {'address': '2001:4860:4860::8844'}
        ]));
    expect(
        ip6Config.routeData,
        equals([
          {'dest': 'fe80::', 'prefix': 64, 'metric': 600},
        ]));
    expect(ip6Config.searches, equals(['search6a', 'search6b']));

    await client.close();
  });

  test('device dhcp config', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));

    var nm = MockNetworkManagerServer(clientAddress);
    await nm.start();
    var dhcp4c = await nm.addDhcp4Config(options: {
      'option4a': DBusString('192.168.0.1'),
      'option4b': DBusUint32(42)
    });
    var dhcp6c = await nm.addDhcp6Config(options: {
      'option6a': DBusString('2001:0db8:85a3:0000:0000:8a2e:0370:1234'),
      'option6b': DBusUint32(42)
    });
    await nm.addDevice(dhcp4Config: dhcp4c, dhcp6Config: dhcp6c);

    var client = NetworkManagerClient(bus: DBusClient(clientAddress));
    await client.connect();

    expect(client.devices, hasLength(1));
    var device = client.devices[0];
    expect(device.dhcp4Config, isNotNull);
    expect(device.dhcp4Config!.options,
        equals({'option4a': '192.168.0.1', 'option4b': 42}));
    expect(device.dhcp6Config, isNotNull);
    expect(
        device.dhcp6Config!.options,
        equals({
          'option6a': '2001:0db8:85a3:0000:0000:8a2e:0370:1234',
          'option6b': 42
        }));

    await client.close();
  });

  test('device disconnect', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));

    var nm = MockNetworkManagerServer(clientAddress);
    await nm.start();
    var d = await nm.addDevice();

    var client = NetworkManagerClient(bus: DBusClient(clientAddress));
    await client.connect();

    expect(client.devices, hasLength(1));
    var device = client.devices[0];
    expect(d.disconnected, isFalse);
    await device.disconnect();
    expect(d.disconnected, isTrue);

    await client.close();
  });

  test('device delete', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));

    var nm = MockNetworkManagerServer(clientAddress);
    await nm.start();
    var d = await nm.addDevice();

    var client = NetworkManagerClient(bus: DBusClient(clientAddress));
    await client.connect();

    expect(client.devices, hasLength(1));
    var device = client.devices[0];
    expect(d.deleted, isFalse);
    await device.delete();
    expect(d.deleted, isTrue);

    await client.close();
  });

  test('generic device', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));

    var nm = MockNetworkManagerServer(clientAddress);
    await nm.start();
    await nm.addDevice(hasGeneric: true, typeDescription: 'TYPE-DESCRIPTION');

    var client = NetworkManagerClient(bus: DBusClient(clientAddress));
    await client.connect();

    expect(client.devices, hasLength(1));
    var device = client.devices[0];
    expect(device.generic, isNotNull);
    expect(device.generic.typeDescription, equals('TYPE-DESCRIPTION'));

    await client.close();
  });

  test('wireless device', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));

    var nm = MockNetworkManagerServer(clientAddress);
    await nm.start();
    var ap1 = await nm.addAccessPoint(
        flags: 0xf,
        frequency: 5745,
        hwAddress: 'AC:CE:55:00:00:01',
        lastSeen: 123456789,
        maxBitrate: 270000,
        mode: 2,
        rsnFlags: 0x188,
        ssid: [104, 101, 108, 108, 111],
        strength: 59,
        wpaFlags: 0x144);
    var ap2 = await nm.addAccessPoint(hwAddress: 'AC:CE:55:00:00:02');
    var ap3 = await nm.addAccessPoint(hwAddress: 'AC:CE:55:00:00:03');
    await nm.addDevice(
        hasWireless: true,
        accessPoints: [ap1, ap2, ap3],
        activeAccessPoint: ap1,
        bitrate: 135000,
        lastScan: 123456789,
        wirelessMode: 2,
        permHwAddress: 'DE:71:CE:00:00:01',
        wirelessCapabilities: 0x1027);

    var client = NetworkManagerClient(bus: DBusClient(clientAddress));
    await client.connect();

    expect(client.devices, hasLength(1));
    var device = client.devices[0];
    expect(device.wireless, isNotNull);
    expect(device.wireless.accessPoints, hasLength(3));
    expect(
        device.wireless.accessPoints[0].hwAddress, equals('AC:CE:55:00:00:01'));
    expect(
        device.wireless.accessPoints[1].hwAddress, equals('AC:CE:55:00:00:02'));
    expect(
        device.wireless.accessPoints[2].hwAddress, equals('AC:CE:55:00:00:03'));
    expect(device.wireless.activeAccessPoint, isNotNull);
    var ap = device.wireless.activeAccessPoint!;
    expect(
        ap.flags,
        equals({
          NetworkManagerWifiAcessPointFlag.privacy,
          NetworkManagerWifiAcessPointFlag.wps,
          NetworkManagerWifiAcessPointFlag.wpsPushButton,
          NetworkManagerWifiAcessPointFlag.wpsPin
        }));
    expect(ap.frequency, equals(5745));
    expect(ap.hwAddress, equals('AC:CE:55:00:00:01'));
    expect(ap.lastSeen, equals(123456789));
    expect(ap.maxBitrate, equals(270000));
    expect(ap.mode, equals(NetworkManagerWifiMode.infra));
    expect(
        ap.rsnFlags,
        equals({
          NetworkManagerWifiAcessPointSecurityFlag.pairCCMP,
          NetworkManagerWifiAcessPointSecurityFlag.groupCCMP,
          NetworkManagerWifiAcessPointSecurityFlag.keyManagementPSK
        }));
    expect(ap.ssid, equals([104, 101, 108, 108, 111]));
    expect(ap.strength, equals(59));
    expect(
        ap.wpaFlags,
        equals({
          NetworkManagerWifiAcessPointSecurityFlag.pairTKIP,
          NetworkManagerWifiAcessPointSecurityFlag.groupTKIP,
          NetworkManagerWifiAcessPointSecurityFlag.keyManagementPSK
        }));
    expect(device.wireless.bitrate, equals(135000));
    expect(device.wireless.lastScan, equals(123456789));
    expect(device.wireless.mode, equals(NetworkManagerWifiMode.infra));
    expect(device.wireless.permHwAddress, equals('DE:71:CE:00:00:01'));
    expect(
        device.wireless.wirelessCapabilities,
        equals({
          NetworkManagerDeviceWifiCapability.cipherWEP40,
          NetworkManagerDeviceWifiCapability.cipherWEP104,
          NetworkManagerDeviceWifiCapability.cipherTKIP,
          NetworkManagerDeviceWifiCapability.rsn,
          NetworkManagerDeviceWifiCapability.mesh
        }));

    await client.close();
  });

  test('device statistics', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));

    var nm = MockNetworkManagerServer(clientAddress);
    await nm.start();
    await nm.addDevice(
        hasStatistics: true, refreshRateMs: 100, rxBytes: 1024, txBytes: 2048);

    var client = NetworkManagerClient(bus: DBusClient(clientAddress));
    await client.connect();

    expect(client.devices, hasLength(1));
    var device = client.devices[0];
    expect(device.statistics, isNotNull);
    expect(device.statistics.refreshRateMs, equals(100));
    expect(device.statistics.rxBytes, equals(1024));
    expect(device.statistics.txBytes, equals(2048));

    await device.statistics.setRefreshRateMs(10);
    expect(device.statistics.refreshRateMs, equals(100));

    await client.close();
  });

  test('no active connections', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));

    var nm = MockNetworkManagerServer(clientAddress);
    await nm.start();

    var client = NetworkManagerClient(bus: DBusClient(clientAddress));
    await client.connect();

    expect(client.activeConnections, isEmpty);

    await client.close();
  });

  test('active connections', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));

    var nm = MockNetworkManagerServer(clientAddress);
    await nm.start();
    await nm.addActiveConnection(id: 'connection1');
    await nm.addActiveConnection(id: 'connection2');
    await nm.addActiveConnection(id: 'connection3');

    var client = NetworkManagerClient(bus: DBusClient(clientAddress));
    await client.connect();

    expect(client.activeConnections, hasLength(3));
    expect(client.activeConnections[0].id, equals('connection1'));
    expect(client.activeConnections[1].id, equals('connection2'));
    expect(client.activeConnections[2].id, equals('connection3'));

    await client.close();
  });

  test('active connection properties', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));

    var nm = MockNetworkManagerServer(clientAddress);
    await nm.start();
    var d1 = await nm.addDevice(hwAddress: 'DE:71:CE:00:00:01');
    var d2 = await nm.addDevice(hwAddress: 'DE:71:CE:00:00:02');
    var ip4c = await nm.addIp4Config(gateway: '192.168.0.1');
    var ip6c = await nm.addIp6Config(
        gateway: '2001:0db8:85a3:0000:0000:8a2e:0370:1234');
    var dhcp4c = await nm.addDhcp4Config(options: {
      'option4a': DBusString('192.168.0.1'),
      'option4b': DBusUint32(42)
    });
    var dhcp6c = await nm.addDhcp6Config(options: {
      'option6a': DBusString('2001:0db8:85a3:0000:0000:8a2e:0370:1234'),
      'option6b': DBusUint32(42)
    });
    await nm.addActiveConnection(
        default4: true,
        default6: true,
        devices: [d1, d2],
        dhcp4Config: dhcp4c,
        dhcp6Config: dhcp6c,
        id: 'ID',
        ip4Config: ip4c,
        ip6Config: ip6c,
        state: 1,
        stateFlags: 0xff,
        type: '802-3-ethernet',
        uuid: '123e4567-e89b-12d3-a456-426614174000',
        vpn: true);

    var client = NetworkManagerClient(bus: DBusClient(clientAddress));
    await client.connect();

    expect(client.activeConnections, hasLength(1));
    var connection = client.activeConnections[0];
    expect(connection.default4, isTrue);
    expect(connection.default6, isTrue);
    expect(connection.devices, hasLength(2));
    expect(connection.devices[0].hwAddress, equals('DE:71:CE:00:00:01'));
    expect(connection.devices[1].hwAddress, equals('DE:71:CE:00:00:02'));
    expect(connection.dhcp4Config, isNotNull);
    expect(connection.dhcp4Config!.options,
        equals({'option4a': '192.168.0.1', 'option4b': 42}));
    expect(connection.dhcp6Config, isNotNull);
    expect(
        connection.dhcp6Config!.options,
        equals({
          'option6a': '2001:0db8:85a3:0000:0000:8a2e:0370:1234',
          'option6b': 42
        }));
    expect(connection.id, equals('ID'));
    expect(connection.ip4Config, isNotNull);
    expect(connection.ip4Config!.gateway, equals('192.168.0.1'));
    expect(connection.ip6Config, isNotNull);
    expect(connection.ip6Config!.gateway,
        equals('2001:0db8:85a3:0000:0000:8a2e:0370:1234'));
    expect(connection.state,
        equals(NetworkManagerActiveConnectionState.activating));
    expect(
        connection.stateFlags,
        equals({
          NetworkManagerActivationStateFlag.isMaster,
          NetworkManagerActivationStateFlag.isSlave,
          NetworkManagerActivationStateFlag.layer2Ready,
          NetworkManagerActivationStateFlag.ip4Ready,
          NetworkManagerActivationStateFlag.ip6Ready,
          NetworkManagerActivationStateFlag.masterHasSlaves,
          NetworkManagerActivationStateFlag.lifetimeBoundToProfileVisibility,
          NetworkManagerActivationStateFlag.external
        }));
    expect(connection.type, equals('802-3-ethernet'));
    expect(connection.uuid, equals('123e4567-e89b-12d3-a456-426614174000'));
    expect(connection.vpn, isTrue);

    await client.close();
  });

  test('add connection', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));

    var nm = MockNetworkManagerServer(clientAddress);
    await nm.start();

    var client = NetworkManagerClient(bus: DBusClient(clientAddress));
    await client.connect();

    var connection = await client.settings.addConnection({});
    expect(connection, isNotNull);
    expect(nm.connectionSettings, hasLength(1));
    expect(nm.connectionSettings[0].unsaved, isFalse);

    await client.close();
  });

  test('add connection unsaved', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));

    var nm = MockNetworkManagerServer(clientAddress);
    await nm.start();

    var client = NetworkManagerClient(bus: DBusClient(clientAddress));
    await client.connect();

    var connection = await client.settings.addConnectionUnsaved({});
    expect(connection, isNotNull);
    expect(nm.connectionSettings, hasLength(1));
    expect(nm.connectionSettings[0].unsaved, isTrue);

    await client.close();
  });
}
