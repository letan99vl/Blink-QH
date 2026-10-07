# QH ECU / Blink-QH

## Nguon
- Tach tu `letan99vl/Blink-Redleo`
- Snapshot nguon: `e025555834f9aac331e54528864a834401131bad`
- Repo dich: `letan99vl/Blink-QH`

## Muc tieu
Ban rieng cho khach hang QH ECU. Giu nguyen logic doc/ghi ECU, protocol va cac cong cu kiem tra tu Blink-Redleo, tach rieng branding va giao dien de phat trien doc lap.

## Giao dien QH v1.0
- Branding: QH ECU / QH ECU RACING
- Tong mau: den, xam kim loai, vang
- Bo thanh dieu huong duoi
- Trang chu dung menu lon de vao:
  - Tuy chon
  - ECU
  - Ban do
  - Auto Tune
  - Du lieu / 3D Fuel Map
  - Du lieu / Live
- Trang Ban do, Auto Tune, ECU, Thiet lap va Map Editor co nut mui ten quay lai o dau trang.
- Dieu huong van dung `data-nav` + `showScreen()` cua Blink-Redleo, khong thay doi logic protocol ECU.

## Commit moc
- Clone source: `a85f0ab89554bec6800d3ce978a4bcf515a0baa2`
- QH UI v1.0: `b6694656647d94c240ff9c4755f5fc0654b5e947`

## Luu y OTA
File `ota/blink_esp32.bin` la binary lon va GitHub connector khong doc duoc bytes de clone truc tiep. Khong dua file rong vao repo QH. Source firmware va workflow build da duoc clone; build lai OTA binary trong repo QH truoc khi phat hanh firmware QH.

## QH color cleanup v1.0.1
- Commit: `f62e16aa4d32f78f666832fd914c57f7d368bbd0`
- Phu lai cac lop RED/BLACK cu bang den-xam kim loai-vang QH.
- Trang thai OFF, menu, icon, map selection, Auto Tune, Settings va editor khong con dung mau do lam mau giao dien.
- Mau do chi giu cho du lieu co y nghia nhu AFR qua giau/heatmap cao va thong bao loi nghiem trong.
- Bo khoang trong bottom navigation cu, cac screen dung full chieu cao.

## QH dashboard v1.0.2
- Commit: `b6fbd6d7d268801306e4c6715c6c18bab0bd479e`
- Thay dashboard Home bang cum dong ho RPM theo anh mau QH ECU: vong cung vang -> cam -> do redline, so RPM lon, x1000, marker live.
- Them cum SPEED ben phai (hien -- km/h cho den khi co nguon speed that), TPS/ECT, va strip TPS/MAP/AFR/ECT/IAT.
- Giu nguyen cac ID live cu de protocol va logic ECU khong doi.
- Them QH FINAL THEME o cuoi HEAD de khoa mau den/xam kim loai/vang sau tat ca CSS legacy.
- Doi cac nhan BLINK con hien thi tren Auto Tune/Settings sang QH.
- Kiem tra static: khong trung ID, khong thieu cac ID live/mapSelect bat buoc.

## QH RPM refinement v1.0.3
- Commit: `921ce940ba0d1faf8b90d1f3611108057c10a6ac`
- Giam kich thuoc gauge, mong vong cung, giam font tick va glow.
- Bo moc 18; gauge hien 0-16 va scale 0-16000 rpm.
- Vong cung mau vang -> cam -> do chi hien den vi tri RPM live; phan chua dat duoc duoc che bang mau xam.
- Marker va vong cung dung chung bien `--rpm-angle`, co transition ngan de chuyen dong muot hon.

## QH inner skin v1.0.7
- Commit: `48b46862fbf5833ae34a0f4b99d1e60271a1faff`
- Dong bo cac trang con theo skin mau: nen carbon, vien vang 2 lop, bevel kim loai, glow vang nhe.
- Settings tiles, input, button, ECU panels, Map cards, Auto Tune cards, editor toolbar/meta deu dung chung skin QH.
- Khong doi logic ECU/protocol; chi thay CSS/UI.

## TANLE RPM transplant v1.0.14
- Commit: `6b7c0305f245666ad9582d1334a5d54a9a3e17f9`
- Be nguyen SVG RPM gauge tu `letan99vl/tanle/live/rpm.html` sang dashboard QH.
- Be logic LED segment/digital digit tu TANLE va noi vao RPM live cua QH qua `rpmLive` an + `qhTanleSetRpm()`.
- Scale 0-16000 rpm, khong doi protocol ECU.
- Kiem tra: khong trung ID, gauge cu da duoc go khoi DOM.

## Auto Tune direct v1.0.17
- Commit: `9e292894db820486d73991c50124a3d26d223507`
- Nut AUTO TUNE trang chu mo thang editor tab AFR do QH, return ve dashboard.
- Man tuneScreen cu duoc giu an trong DOM de bao toan mode/3-run state, khong con route hien thi.
- Chuyen recordBtn vao toolbar editor va chi hien khi tab measured; button doi GHI AFR / DUNG GHI AFR theo recording state.
- Khong trung ID sau patch.

## Full core restore v1.0.18
- Root cause: sau khi clone, workflow `apply-real-protocol.yml` da tu giai nen snapshot cu trong `tools/*.gz.b64` va ghi de `redleo_real_protocol.js`, lam QH chi con protocol ~39 KB thay vi loi day du ~259 KB.
- Da vo hieu hoa legacy installer nay trong Blink-QH; ESP32-S3 khong duoc dung cho du an QH.
- `redleo_real_protocol.js` da khoi phuc 1:1 tu `Blink-Redleo/main`, blob SHA `51777e874a776f633e0b318665b57c736fabbf07`.
- Phan cung QH dung ESP32 thuong, FW 1.8. Source FW1.8 lay tu REDLEO commit `f5ade0d61502ab1a8544aa7c413f6be71c449e97`.
- OTA manifest QH: version 1.8, URL tro ve `Blink-QH/main/ota/blink_esp32.bin`.
- Regression run `37598502058`: PASS syntax, row orientation, map selection, AFR cross-family, injection cam calculator, ECU feature matrix, V8, 9.1X, V9 routing, 9.2 page6, V10.2 page6/A2, Ultra Pro1 page6/A2, Ultra Pro2.
- Khong thay doi QH skin/home flow; day la khoi phuc core chuc nang.

## Map editor layout v1.0.20
- Header map bo nut back; chi con title/subtitle + BLE status.
- Hang cong cu dau: QUAY VE | DOC HIEN TAI | LUU HIEN TAI.
- Nut PHONG TO MAP doi xuong editorInfo, nam ngay ben phai AFR LIVE.
- Mobile/editorInfo dung 3 cot: TPS/RPM | AFR LIVE | PHONG TO MAP; ECT chi hien tren man rong.
- Commit layout: `1da6c6ab82aa60f1802048c72c15c53f0729140a`; fix shape back: `95ab2d52e5d16118c25042ede67d82e75611737d`.

## QH iOS IPA v1.0.21
- Source native iOS: `iOS/QHECU/Main.swift`, `iOS/QHECU/Info.plist`, `iOS/project.yml`.
- Wrapper dung WKWebView mo truc tiep `https://letan99vl.github.io/Blink-QH/`.
- BLE iOS dung CoreBluetooth native va inject Web Bluetooth bridge cho requestDevice/connect/getPrimaryService/getCharacteristic/startNotifications/writeValue.
- Bundle ID hien tai: `vn.qhecu.app`; display name: `QH ECU`; iOS >= 15.
- Workflow: `.github/workflows/build-ios-ipa.yml`.
- Build run thanh cong: `37644174078`; artifact ID `11494290268`.
- IPA: `QH-ECU-v1.0.21.ipa`; SHA256 `db1a9c58ba1cbb9fe23648a5a3367e4ba1df3264d43192bf5ae96fbe3a3e9d2a`.
- IPA hien tai la unsigned, phu hop sideload/ky lai. TestFlight/App Store can provisioning/certificate cua Apple Developer.


## Read All stall recovery v1.0.25
- Symptom: Read All could intermittently stop around 63-64% and remain loading until timeout.
- Root cause class: one lost middle RAW_RX BLE notification leaves the 8-10 KB assembler incomplete even though ECU already returned the frame.
- Added an 8-second Read All no-progress watchdog.
- Read All now retries automatically once after a stall/0xAB timeout.
- If the negotiated RX stream was above 96B (normally 160B), the retry degrades runtime RX to 96B through FW1.8 RXJUMBO control to reduce BLE queue pressure.
- No ESP32 firmware update is required; QH FW1.8 already accepts RXJUMBO payloads 64..160B.
- Read All progress remains visible as percent and received/total bytes.


## Blink Read All sync + FW2.0 v1.0.26
- QH was originally cloned while Blink used classic ESP32 bridge FW1.9; the later QH rollback to FW1.8 was not part of the original clone state.
- QH protocol core is resynced exactly to current Blink-Redleo Read All release core.
- QH classic ESP32 firmware is resynced to Blink FW2.0 transport behavior.
- FW2.0 hardens 8-10 KB Read All streaming: jumbo RX delay for >=8000B is 14 ms, yield interval is every 4 packets, and long-jumbo yield pause is 24 ms.
- QH firmware keeps its own OTA manifest under Blink-QH.
- Build workflow now publishes QH OTA manifest as version 2.0.


## Read All residual stall hardening - QH P.b 1.0.27 / ESP32 FW2.1

- Real-hardware observation after FW2.0: Read All improved substantially but still stalled intermittently, about 2 failures in 10 repeated reads.
- Blink-Redleo had no commit newer than FW2.0 for this residual case at the time of this checkpoint.
- Root cause class remains BLE notification loss inside the 8-10 KB RAW_RX stream:
  - app reassembly is offset-addressed and requires every unique offset;
  - FW2.0 repeated only START/END chunks, while each middle chunk was still sent only once;
  - one lost middle notification can therefore leave Read All incomplete.
- QH FW2.1 adds a reliability-only two-pass stream for jumbo responses >= 8000 bytes:
  - pass 1 sends all chunks except the final END chunk;
  - pass 2 sends the whole frame again and includes END;
  - duplicate START/offset chunks are safe because the web reassembler de-duplicates by offset;
  - END is intentionally withheld from pass 1 so the app cannot resolve 100% before the redundant second pass has run;
  - 70 ms gap separates the two passes to reduce correlated host-side BLE queue loss.
- Smaller responses and non-jumbo paths keep the existing behavior.
- Existing FW2.0 pacing remains in place for huge jumbo frames (14 ms packet pacing, yield every 4 packets, 24 ms long-frame yield pause).
- Existing app watchdog + one automatic full Read All retry remains as the final fallback if the same offset is somehow lost in both passes.
- Firmware source version: 2.1.
- OTA manifest version: 2.1.
- OTA SHA256: 904022b052689a0e736a8909954a90d1a6266065f88787b9406a4f3e4d2bbb5d.
- FW2.1 OTA build workflow completed successfully and pushed binary in commit 393f803210901705f0ca456c22102d1abc3a57f1.
- Protocol/UI PB bumped to QH 1.0.27 in commit 3a44d4f6d50b6e9ba6835893b754420ce9a08978.
- Workflow concurrency protection remains enabled so stale firmware jobs cannot overwrite a newer OTA manifest.


## OTA reliability fix - QH P.b 1.0.28

- Symptom: BLE OTA could run briefly, then UI showed "Đã hủy cập nhật firmware".
- Two separate issues were identified:
  1. The real OTA error was hidden because the app catch path sent OTA_BLE_ABORT and the later OTA:ABORT status overwrote the original failure message.
  2. Firmware data used 160-byte write-without-response bursts, with only every 8th packet used as a write-with-response barrier. A dropped mobile/WebView BLE Write Command caused the next firmware offset to arrive out of sequence, so ESP32 correctly raised OTA:ERR=SEQ and aborted the partial update.
- App fix:
  - firmware BLE packets now use write-with-response for EVERY packet;
  - default OTA data payload is 100 bytes, with adaptive fallback 60 -> 20 -> 12 bytes if the client rejects the current ATT size;
  - transfer yields briefly after each packet so OTA error notifications can be processed before another packet is queued;
  - cleanup OTA:ABORT no longer replaces the original error message;
  - QH manifest fallback URLs now point only to Blink-QH, never Blink-Redleo.
- This is an app/web fix and is specifically designed to allow existing FW2.0 hardware to update reliably to FW2.1.
- Tradeoff: OTA is intentionally slower than the previous burst path, but sequential flash transport is much safer.
- Main implementation commit: a2c59ad355126ed0160f00c3c9b39724063e62d5.
- PB bump commit: 1e339cadbf7740eb6eb9a929ca1061187588a50b.
