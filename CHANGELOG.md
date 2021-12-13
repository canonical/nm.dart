# Changelog

## 0.4.2

* Add NetworkManagerClient.state.
* Fix device state reason.

## 0.4.1

* Add NetworkManagerClient.addAndActivateConnection().
* Improve test coverage.

## 0.4.0

* Fix detection of removed device/connection device when they re-appear.

## 0.3.0

* Add NetworkManagerClient.activate/deactivateConnection().
* Fix typo in NetworkManagerWifiAccessPointFlag, NetworkManagerWifiAccessPointSecurityFlag enum names.
* Reliably detect when an object is removed, rather than just some of its interfaces.
* Add more toString() methods for easier debugging.
* Use dbus 0.5.
* Rename test file so can just run 'dart test'.

## 0.2.0

* Various new API additions and fixes.
* Make device interface objects null if the interface is not present.
* Add equality operators to public classes.
* Replace setters with methods so they can be async.
* Added many more tests.

## 0.1.0

* Initial release
