# QH ECU iOS wrapper

Native iOS wrapper for Blink-QH.

- Web UI: https://letan99vl.github.io/Blink-QH/
- Native BLE: CoreBluetooth bridge that exposes the Web Bluetooth calls used by Blink-QH.
- Display name: QH ECU
- Bundle ID: vn.qhecu.app
- Minimum iOS: 15.0
- IPA build: GitHub Actions workflow `Build QH ECU IPA`.

The generated IPA is unsigned. It is intended for sideloading/signing outside the App Store or for use as the source wrapper before TestFlight/App Store signing.
