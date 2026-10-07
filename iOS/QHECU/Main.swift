import UIKit
import WebKit
import CoreBluetooth

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        application.isIdleTimerDisabled = true
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.backgroundColor = .black
        window.rootViewController = WebViewController()
        window.makeKeyAndVisible()
        self.window = window
        return true
    }
}

final class WebViewController: UIViewController, WKNavigationDelegate {
    private var webView: WKWebView!
    private var bleBridge: BLEBridge!

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    override var prefersHomeIndicatorAutoHidden: Bool { true }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        let config = WKWebViewConfiguration()
        config.websiteDataStore = .default()
        config.defaultWebpagePreferences.allowsContentJavaScript = true
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []

        let userContent = WKUserContentController()
        userContent.addUserScript(
            WKUserScript(
                source: Self.webBluetoothBootstrap,
                injectionTime: .atDocumentStart,
                forMainFrameOnly: true
            )
        )
        config.userContentController = userContent

        webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.isOpaque = false
        webView.backgroundColor = .black
        webView.scrollView.backgroundColor = .black
        webView.scrollView.bounces = false
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.allowsBackForwardNavigationGestures = false

        view.addSubview(webView)
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        bleBridge = BLEBridge(webView: webView, presenter: self)
        userContent.add(bleBridge, name: "ble")

        loadQH()
    }

    private func loadQH() {
        guard let url = URL(string: "https://letan99vl.github.io/Blink-QH/?ios=1&nativeble=1&v=1.0.21") else { return }
        let request = URLRequest(
            url: url,
            cachePolicy: .reloadIgnoringLocalCacheData,
            timeoutInterval: 30
        )
        webView.load(request)
    }

    private static let webBluetoothBootstrap = #"""
    (() => {
      if (window.__QH_IOS_NATIVE_BLE__) return;
      window.__QH_IOS_NATIVE_BLE__ = true;

      const pending = new Map();
      const chars = new Map();
      let seq = 1;
      let currentDevice = null;

      const normalize = (v) => String(v || '').toLowerCase();

      function toBytes(value) {
        if (value instanceof ArrayBuffer) return Array.from(new Uint8Array(value));
        if (ArrayBuffer.isView(value)) {
          return Array.from(new Uint8Array(value.buffer, value.byteOffset, value.byteLength));
        }
        if (Array.isArray(value)) return value.map(v => Number(v) & 255);
        return [];
      }

      function callNative(action, extra = {}) {
        return new Promise((resolve, reject) => {
          const id = seq++;
          pending.set(id, { resolve, reject });
          try {
            window.webkit.messageHandlers.ble.postMessage({ id, action, ...extra });
          } catch (e) {
            pending.delete(id);
            reject(e);
          }
        });
      }

      window.__qhBleResolve = (id, ok, payload) => {
        const slot = pending.get(Number(id));
        if (!slot) return;
        pending.delete(Number(id));
        if (ok) {
          slot.resolve(payload);
          return;
        }
        const info = payload || {};
        const err = new Error(info.message || 'Bluetooth error');
        err.name = info.name || 'NetworkError';
        slot.reject(err);
      };

      class QHCharacteristic {
        constructor(uuid) {
          this.uuid = normalize(uuid);
          this.value = null;
          this._listeners = new Set();
          chars.set(this.uuid, this);
        }

        async startNotifications() {
          await callNative('subscribe', { uuid: this.uuid });
          return this;
        }

        addEventListener(type, listener) {
          if (type === 'characteristicvaluechanged' && typeof listener === 'function') {
            this._listeners.add(listener);
          }
        }

        removeEventListener(type, listener) {
          if (type === 'characteristicvaluechanged') this._listeners.delete(listener);
        }

        async writeValueWithoutResponse(value) {
          await callNative('write', {
            uuid: this.uuid,
            bytes: toBytes(value),
            withResponse: false
          });
        }

        async writeValueWithResponse(value) {
          await callNative('write', {
            uuid: this.uuid,
            bytes: toBytes(value),
            withResponse: true
          });
        }

        async writeValue(value) {
          await this.writeValueWithResponse(value);
        }
      }

      function characteristic(uuid) {
        const key = normalize(uuid);
        return chars.get(key) || new QHCharacteristic(key);
      }

      window.__qhBleNotify = (uuid, bytes) => {
        const c = characteristic(uuid);
        const u8 = new Uint8Array(Array.isArray(bytes) ? bytes : []);
        c.value = new DataView(u8.buffer);
        const ev = { type: 'characteristicvaluechanged', target: c };
        for (const fn of Array.from(c._listeners)) {
          try { fn.call(c, ev); } catch (e) { console.error(e); }
        }
      };

      function makeDevice(info) {
        const listeners = new Map();

        const service = {
          uuid: '',
          async getCharacteristic(uuid) {
            return characteristic(uuid);
          }
        };

        const server = {
          device: null,
          connected: false,
          async getPrimaryService(uuid) {
            service.uuid = normalize(uuid);
            return service;
          }
        };

        const device = {
          id: String(info?.id || ''),
          name: String(info?.name || 'QH ECU'),
          gatt: {
            connected: false,
            async connect() {
              await callNative('connect', { peripheralId: device.id });
              this.connected = true;
              server.connected = true;
              return server;
            },
            disconnect() {
              this.connected = false;
              server.connected = false;
              callNative('disconnect').catch(() => {});
            }
          },
          addEventListener(type, listener) {
            if (typeof listener !== 'function') return;
            if (!listeners.has(type)) listeners.set(type, new Set());
            listeners.get(type).add(listener);
          },
          removeEventListener(type, listener) {
            listeners.get(type)?.delete(listener);
          },
          _emit(type) {
            for (const fn of Array.from(listeners.get(type) || [])) {
              try { fn.call(device, { type, target: device }); } catch (e) { console.error(e); }
            }
          }
        };

        server.device = device;
        currentDevice = device;
        return device;
      }

      window.__qhBleDisconnected = () => {
        if (!currentDevice) return;
        currentDevice.gatt.connected = false;
        currentDevice._emit('gattserverdisconnected');
      };

      const bluetooth = {
        async requestDevice(options = {}) {
          const filters = Array.isArray(options.filters) ? options.filters : [];
          let prefix = 'BLINK-REDLEO';
          for (const f of filters) {
            if (f && typeof f.namePrefix === 'string' && f.namePrefix) {
              prefix = f.namePrefix;
              break;
            }
          }
          const info = await callNative('requestDevice', { prefix });
          return makeDevice(info);
        },
        async getAvailability() { return true; },
        async setScreenDimEnabled() { return true; }
      };

      try {
        Object.defineProperty(navigator, 'bluetooth', {
          value: bluetooth,
          configurable: true,
          enumerable: true
        });
      } catch (_) {
        try { navigator.bluetooth = bluetooth; } catch (_) {}
      }
    })();
    """#
}

final class BLEBridge: NSObject, WKScriptMessageHandler, CBCentralManagerDelegate, CBPeripheralDelegate {
    private weak var webView: WKWebView?
    private weak var presenter: UIViewController?

    private var central: CBCentralManager!
    private var discovered: [UUID: (CBPeripheral, Int)] = [:]
    private var selected: CBPeripheral?
    private var characteristics: [String: CBCharacteristic] = [:]

    private var scanRequestID: Int?
    private var scanPrefix = "BLINK-REDLEO"
    private var connectRequestID: Int?
    private var subscribeRequests: [String: Int] = [:]
    private var writeRequests: [String: Int] = [:]

    private let serviceUUID = CBUUID(string: "afaf0001-7c35-4a6d-9f0e-2ea3117f1000")
    private let characteristicUUIDs = [
        CBUUID(string: "afaf0002-7c35-4a6d-9f0e-2ea3117f1000"),
        CBUUID(string: "afaf0003-7c35-4a6d-9f0e-2ea3117f1000"),
        CBUUID(string: "afaf0004-7c35-4a6d-9f0e-2ea3117f1000"),
        CBUUID(string: "afaf0005-7c35-4a6d-9f0e-2ea3117f1000")
    ]

    init(webView: WKWebView, presenter: UIViewController) {
        self.webView = webView
        self.presenter = presenter
        super.init()
        self.central = CBCentralManager(delegate: self, queue: .main)
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard
            let body = message.body as? [String: Any],
            let action = body["action"] as? String
        else { return }

        let requestID = intValue(body["id"]) ?? 0

        switch action {
        case "requestDevice":
            let prefix = (body["prefix"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)
            beginScan(requestID: requestID, prefix: (prefix?.isEmpty == false ? prefix! : "BLINK-REDLEO"))

        case "connect":
            connect(requestID: requestID, peripheralID: body["peripheralId"] as? String)

        case "subscribe":
            subscribe(requestID: requestID, uuid: body["uuid"] as? String)

        case "write":
            let bytes = byteArray(body["bytes"])
            let withResponse = (body["withResponse"] as? Bool) ?? true
            write(requestID: requestID, uuid: body["uuid"] as? String, bytes: bytes, withResponse: withResponse)

        case "disconnect":
            if let p = selected {
                central.cancelPeripheralConnection(p)
            }
            resolve(requestID, ok: true, payload: ["ok": true])

        default:
            reject(requestID, name: "NotSupportedError", message: "Unsupported BLE action: \(action)")
        }
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            if scanRequestID != nil { startScanNow() }
            return
        }

        if let id = scanRequestID, central.state != .unknown && central.state != .resetting {
            scanRequestID = nil
            reject(id, name: "NotFoundError", message: "Bluetooth chưa bật hoặc không khả dụng.")
        }
    }

    private func beginScan(requestID: Int, prefix: String) {
        if scanRequestID != nil {
            reject(requestID, name: "InvalidStateError", message: "Đang quét thiết bị Bluetooth.")
            return
        }

        scanRequestID = requestID
        scanPrefix = prefix
        discovered.removeAll()
        central.stopScan()

        if central.state == .poweredOn {
            startScanNow()
        } else if central.state != .unknown && central.state != .resetting {
            scanRequestID = nil
            reject(requestID, name: "NotFoundError", message: "Hãy bật Bluetooth trên iPhone.")
        }
    }

    private func startScanNow() {
        guard scanRequestID != nil else { return }
        discovered.removeAll()
        central.scanForPeripherals(
            withServices: [serviceUUID],
            options: [CBCentralManagerScanOptionAllowDuplicatesKey: false]
        )

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.6) { [weak self] in
            self?.finishScanAndShowPicker()
        }
    }

    func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String : Any],
        rssi RSSI: NSNumber
    ) {
        let advName = advertisementData[CBAdvertisementDataLocalNameKey] as? String
        let name = peripheral.name ?? advName ?? ""
        if !scanPrefix.isEmpty && !name.hasPrefix(scanPrefix) { return }
        discovered[peripheral.identifier] = (peripheral, RSSI.intValue)
    }

    private func finishScanAndShowPicker() {
        guard let requestID = scanRequestID else { return }
        central.stopScan()

        let devices = discovered.values.sorted { lhs, rhs in
            lhs.1 > rhs.1
        }

        guard !devices.isEmpty else {
            scanRequestID = nil
            reject(requestID, name: "NotFoundError", message: "Không tìm thấy QH ECU / BLINK-REDLEO.")
            return
        }

        guard let presenter else {
            scanRequestID = nil
            reject(requestID, name: "NotFoundError", message: "Không mở được danh sách Bluetooth.")
            return
        }

        let alert = UIAlertController(
            title: "Chọn QH ECU",
            message: "Thiết bị Bluetooth tìm thấy",
            preferredStyle: .alert
        )

        for (peripheral, rssi) in devices.prefix(12) {
            let title = "\(peripheral.name ?? "BLINK-REDLEO")  ·  \(rssi) dBm"
            alert.addAction(UIAlertAction(title: title, style: .default) { [weak self] _ in
                guard let self else { return }
                self.scanRequestID = nil
                self.selected = peripheral
                self.characteristics.removeAll()
                self.resolve(
                    requestID,
                    ok: true,
                    payload: [
                        "id": peripheral.identifier.uuidString,
                        "name": peripheral.name ?? "QH ECU"
                    ]
                )
            })
        }

        alert.addAction(UIAlertAction(title: "QUÉT LẠI", style: .default) { [weak self] _ in
            guard let self else { return }
            self.discovered.removeAll()
            self.startScanNow()
        })

        alert.addAction(UIAlertAction(title: "HỦY", style: .cancel) { [weak self] _ in
            guard let self else { return }
            self.scanRequestID = nil
            self.reject(requestID, name: "NotFoundError", message: "Đã hủy chọn thiết bị Bluetooth.")
        })

        presenter.present(alert, animated: true)
    }

    private func connect(requestID: Int, peripheralID: String?) {
        guard central.state == .poweredOn else {
            reject(requestID, name: "NetworkError", message: "Bluetooth chưa sẵn sàng.")
            return
        }

        if let id = peripheralID,
           let uuid = UUID(uuidString: id),
           let found = discovered[uuid]?.0 {
            selected = found
        }

        guard let peripheral = selected else {
            reject(requestID, name: "NotFoundError", message: "Chưa chọn thiết bị QH ECU.")
            return
        }

        connectRequestID = requestID
        characteristics.removeAll()
        peripheral.delegate = self

        if peripheral.state == .connected {
            peripheral.discoverServices([serviceUUID])
        } else {
            central.connect(peripheral, options: nil)
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices([serviceUUID])
    }

    func centralManager(
        _ central: CBCentralManager,
        didFailToConnect peripheral: CBPeripheral,
        error: Error?
    ) {
        if let id = connectRequestID {
            connectRequestID = nil
            reject(id, name: "NetworkError", message: error?.localizedDescription ?? "Kết nối BLE thất bại.")
        }
    }

    func centralManager(
        _ central: CBCentralManager,
        didDisconnectPeripheral peripheral: CBPeripheral,
        error: Error?
    ) {
        characteristics.removeAll()
        subscribeRequests.removeAll()
        writeRequests.removeAll()
        sendJS("__qhBleDisconnected", args: [])
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error {
            failConnect(error.localizedDescription)
            return
        }

        guard let service = peripheral.services?.first(where: { $0.uuid == serviceUUID }) else {
            failConnect("Không tìm thấy BLE service của QH ECU.")
            return
        }

        peripheral.discoverCharacteristics(characteristicUUIDs, for: service)
    }

    func peripheral(
        _ peripheral: CBPeripheral,
        didDiscoverCharacteristicsFor service: CBService,
        error: Error?
    ) {
        if let error {
            failConnect(error.localizedDescription)
            return
        }

        for characteristic in service.characteristics ?? [] {
            characteristics[characteristic.uuid.uuidString.lowercased()] = characteristic
        }

        let missing = characteristicUUIDs.filter {
            characteristics[$0.uuidString.lowercased()] == nil
        }

        guard missing.isEmpty else {
            failConnect("Thiếu BLE characteristic của QH ECU.")
            return
        }

        if let id = connectRequestID {
            connectRequestID = nil
            resolve(id, ok: true, payload: ["connected": true])
        }
    }

    private func failConnect(_ message: String) {
        if let id = connectRequestID {
            connectRequestID = nil
            reject(id, name: "NetworkError", message: message)
        }
    }

    private func subscribe(requestID: Int, uuid: String?) {
        guard let characteristic = findCharacteristic(uuid) else {
            reject(requestID, name: "NotFoundError", message: "Không tìm thấy characteristic.")
            return
        }

        let key = characteristic.uuid.uuidString.lowercased()
        subscribeRequests[key] = requestID

        if characteristic.isNotifying {
            subscribeRequests[key] = nil
            resolve(requestID, ok: true, payload: ["notifying": true])
            return
        }

        selected?.setNotifyValue(true, for: characteristic)
    }

    func peripheral(
        _ peripheral: CBPeripheral,
        didUpdateNotificationStateFor characteristic: CBCharacteristic,
        error: Error?
    ) {
        let key = characteristic.uuid.uuidString.lowercased()
        guard let requestID = subscribeRequests.removeValue(forKey: key) else { return }

        if let error {
            reject(requestID, name: "NetworkError", message: error.localizedDescription)
        } else {
            resolve(requestID, ok: true, payload: ["notifying": characteristic.isNotifying])
        }
    }

    func peripheral(
        _ peripheral: CBPeripheral,
        didUpdateValueFor characteristic: CBCharacteristic,
        error: Error?
    ) {
        guard error == nil, let data = characteristic.value else { return }
        let bytes = [UInt8](data)
        sendJS(
            "__qhBleNotify",
            args: [characteristic.uuid.uuidString.lowercased(), bytes]
        )
    }

    private func write(
        requestID: Int,
        uuid: String?,
        bytes: [UInt8],
        withResponse requestedResponse: Bool
    ) {
        guard let peripheral = selected, peripheral.state == .connected else {
            reject(requestID, name: "NetworkError", message: "QH ECU chưa kết nối.")
            return
        }

        guard let characteristic = findCharacteristic(uuid) else {
            reject(requestID, name: "NotFoundError", message: "Không tìm thấy characteristic ghi.")
            return
        }

        var type: CBCharacteristicWriteType = requestedResponse ? .withResponse : .withoutResponse

        if type == .withoutResponse && !characteristic.properties.contains(.writeWithoutResponse) {
            type = .withResponse
        }
        if type == .withResponse && !characteristic.properties.contains(.write) {
            if characteristic.properties.contains(.writeWithoutResponse) {
                type = .withoutResponse
            } else {
                reject(requestID, name: "NotSupportedError", message: "Characteristic không hỗ trợ ghi.")
                return
            }
        }

        let maxLength = peripheral.maximumWriteValueLength(for: type)
        guard bytes.count <= maxLength else {
            reject(
                requestID,
                name: "DataError",
                message: "Gói BLE \(bytes.count)B vượt MTU \(maxLength)B."
            )
            return
        }

        let data = Data(bytes)
        let key = characteristic.uuid.uuidString.lowercased()

        if type == .withResponse {
            writeRequests[key] = requestID
            peripheral.writeValue(data, for: characteristic, type: .withResponse)
        } else {
            peripheral.writeValue(data, for: characteristic, type: .withoutResponse)
            resolve(requestID, ok: true, payload: ["written": bytes.count])
        }
    }

    func peripheral(
        _ peripheral: CBPeripheral,
        didWriteValueFor characteristic: CBCharacteristic,
        error: Error?
    ) {
        let key = characteristic.uuid.uuidString.lowercased()
        guard let requestID = writeRequests.removeValue(forKey: key) else { return }

        if let error {
            reject(requestID, name: "NetworkError", message: error.localizedDescription)
        } else {
            resolve(requestID, ok: true, payload: ["written": true])
        }
    }

    private func findCharacteristic(_ uuid: String?) -> CBCharacteristic? {
        guard let uuid else { return nil }
        return characteristics[uuid.lowercased()]
    }

    private func intValue(_ value: Any?) -> Int? {
        if let n = value as? NSNumber { return n.intValue }
        if let i = value as? Int { return i }
        return nil
    }

    private func byteArray(_ value: Any?) -> [UInt8] {
        guard let array = value as? [Any] else { return [] }
        return array.compactMap { item in
            if let n = item as? NSNumber { return UInt8(truncating: n) }
            if let i = item as? Int { return UInt8(i & 255) }
            return nil
        }
    }

    private func resolve(_ id: Int, ok: Bool, payload: Any) {
        sendJS("__qhBleResolve", args: [id, ok, payload])
    }

    private func reject(_ id: Int, name: String, message: String) {
        resolve(id, ok: false, payload: ["name": name, "message": message])
    }

    private func sendJS(_ function: String, args: [Any]) {
        guard let webView else { return }

        let safeArgs = args.map { Self.jsonLiteral($0) }.joined(separator: ",")
        let script = "window.\(function) && window.\(function)(\(safeArgs));"

        DispatchQueue.main.async {
            webView.evaluateJavaScript(script, completionHandler: nil)
        }
    }

    private static func jsonLiteral(_ value: Any) -> String {
        if value is NSNull { return "null" }

        if JSONSerialization.isValidJSONObject(["v": value]),
           let data = try? JSONSerialization.data(withJSONObject: ["v": value], options: []),
           let text = String(data: data, encoding: .utf8),
           let colon = text.firstIndex(of: ":") {
            let start = text.index(after: colon)
            let end = text.index(before: text.endIndex)
            return String(text[start..<end])
        }

        return "null"
    }
}
