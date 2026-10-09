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


## OTA abort-mask follow-up - QH P.b 1.0.29

- Screenshot evidence showed the UI still displaying the generic "Đã hủy cập nhật firmware" banner after an OTA failure.
- Repo inspection confirmed current 1.0.28 had only one OTA handler and the new reliable per-packet write path, so the screenshot was consistent with a stale pre-1.0.28 page/tab or an ABORT cleanup notification racing the final error UI.
- 1.0.29 adds an explicit otaAbortCleanup flag.
- When otaInstall() sends OTA_BLE_ABORT only to clean up after an already-detected failure, the later OTA:ABORT notification is now silent and cannot create/overwrite the error banner.
- Generic abort text "Đã hủy cập nhật firmware." was removed from the current source. If OTA fails on 1.0.29, the UI must show the real error (SEQ/FLASH/HASH/DATA/GATT/etc.) or a diagnostic "Phiên OTA đã dừng..." message only for a non-cleanup abort.
- Reliable OTA transport from 1.0.28 remains: every firmware packet uses write-with-response, starting at 100B with 60 -> 20 -> 12B fallback.
- Implementation/PB commit: 75b9074720120091e0f9543aad9d86afc47bd667.


## OTA Windows Turbo balance - QH P.b 1.0.30

- User feedback on P.b 1.0.29: OTA no longer immediately failed, but Windows Chrome transfer became unacceptably slow because every firmware packet waited for a GATT response.
- Existing FW1.9 supports safe desktop TX probing (TXPROBE) and the web layer already records the largest proven payload in window.blinkBridgeTxPayload.
- P.b 1.0.30 adds platform-adaptive OTA pacing:
  - Windows Chromium + adaptive TX probe: use the proven payload (normally up to 160B);
  - Turbo uses a 2-packet cadence: first packet without response, second packet with response as a hard flow-control barrier;
  - this is intentionally much more conservative than the historical 8-packet burst that could trigger OTA:ERR=SEQ;
  - iOS/mobile/non-probed clients stay in Safe mode: 100B and write-with-response on every packet.
- If Windows Turbo still triggers OTA:ERR=SEQ, the app automatically cleans the partial session and restarts once from byte zero in Safe mode.
- UI shows the active mode: TURBO <N>B · ACK 1/2 or SAFE <N>B · ACK MỖI GÓI.
- Main implementation/PB commit: c6c1efe140c738e592b36b2f66955389a8e0f39b.


## MOC FALLBACK: CACH UPDATE OTA ON DINH

Ten chinh thuc trong du an: **Cach update OTA on dinh**.

- Day la moc fallback phai giu lai neu cac thu nghiem OTA nhanh ve sau bi loi.
- Snapshot duoc khoa tai branch: `backup/ota-on-dinh-1.0.30`.
- Snapshot commit: `bb4e57e94e0ca6f9652c3d04316c4020654eb048`.
- Logic on dinh tren Windows Chromium:
  - dung TX payload da probe thanh cong (thuong 160B);
  - 1 packet nhanh + packet ke tiep write-with-response;
  - barrier/ACK moi 2 packet;
  - neu can fallback cuoi cung thi Safe mode ACK moi packet.
- Khong duoc xoa branch backup nay khi toi uu OTA sau nay.
- Neu OTA moi bi mat on dinh, uu tien quay lai dung moc nay truoc khi thu nghiem tiep.

## OTA NHANH FW1.9 - QH P.b 1.0.31

- User da ha thiet bi test ve ESP32 FW1.9 va yeu cau cach update nhanh nhat cho FW1.9.
- QH 1.0.31 dung dung Turbo OTA nhanh nhat da tung duoc Blink dung cho FW1.9:
  - Windows Chromium chi;
  - TXPROBE chon payload lon nhat da chung minh on dinh, thuong 160B;
  - 7 packet write-without-response + packet thu 8 write-with-response lam barrier;
  - yield 2 ms giua cac packet khong ACK;
  - UI hien: `OTA NHANH FW1.9 · <N>B · ACK 1/8`.
- Tu dong fallback theo 3 tang:
  1. OTA NHANH FW1.9: ACK 1/8.
  2. Neu gap OTA:ERR=SEQ -> tu restart tu byte 0 bang **Cach update OTA on dinh**: ACK 1/2.
  3. Neu van SEQ -> tu restart lan cuoi bang SAFE: ACK moi packet.
- iOS/mobile/non-probed client khong dung Turbo FW1.9; giu duong an toan.
- Main implementation/PB commit: `5e74af1dbc6541e49aeb80de75d45eafa4a428b3`.


## OTA FAST FW1.9 ROLLBACK - QH P.b 1.0.32

- P.b 1.0.31 thu nghiem OTA NHANH FW1.9 (ACK 1/8) bi loi tren thiet bi test thuc te.
- Quyet dinh: BO DUONG TURBO 1/8 khoi main.
- Main da rollback index.html ve dung snapshot **Cach update OTA on dinh** tu branch `backup/ota-on-dinh-1.0.30`.
- P.b duoc tang thanh 1.0.32 chi de nhan biet rollback da deploy; logic OTA la logic on dinh cua 1.0.30:
  - Windows Chromium dung TX payload da probe;
  - ACK/barrier moi 2 packet;
  - neu Turbo ngan bi SEQ thi tu fallback Safe ACK moi packet.
- Khong duoc phuc hoi logic ACK 1/8 cua 1.0.31 neu chua co mot co che retry/ack theo offset chac chan hon.
- Rollback commit: `da6e2431a7ae35f9435d211943fcd7dfa7e79fd4`.


## OTA FAST FW1.9 ACK 1/4 EXPERIMENT - QH P.b 1.0.33

- Muc tieu: nhanh hon "Cach update OTA on dinh" ma khong lap lai loi cua thu nghiem ACK 1/8.
- Pham vi: Windows Chromium + ESP32 FW1.9 da TXPROBE thanh cong.
- Logic thu nghiem:
  - payload dung gia tri TXPROBE da xac nhan, thuong 160B;
  - ACK/barrier moi 4 packet;
  - yield 2 ms giua cac packet no-response;
  - neu gap OTA:ERR=SEQ -> tu reset phien OTA va quay ve **Cach update OTA on dinh** ACK 1/2;
  - neu fallback on dinh van SEQ -> tu chuyen SAFE ACK moi packet.
- Thu nghiem ACK 1/8 cua P.b 1.0.31 da bi danh dau FAIL va khong duoc dung lai.
- Moc fallback bat bien:
  - branch: `backup/ota-on-dinh-1.0.30`
  - snapshot: `bb4e57e94e0ca6f9652c3d04316c4020654eb048`
- Main implementation commit: `89e3b6eaee9a5731c0c5b98be65ccd4cd77598dc`.


## OTA synced back to current Blink - QH P.b 1.0.34

- User requested to stop QH-specific OTA experiments and return to the OTA method currently used by Blink-Redleo.
- QH OTA block in index.html was replaced with the current Blink-Redleo OTA implementation.
- Only QH-specific changes kept:
  - OTA manifest fallback URLs point to letan99vl/Blink-QH;
  - user-facing BLE connection wording says QH instead of Blink.
- Current Blink OTA behavior now used by QH:
  - firmware BLE chunk starts at 160 bytes;
  - every 8th packet uses write-with-response as a flow-control barrier;
  - non-barrier packets use write-without-response with 2 ms yield;
  - ATT payload automatically steps down 160 -> 100 -> 60 -> 20 -> 12 if needed;
  - Live ECU traffic is paused during OTA;
  - first OTA error is preserved for the final failure message.
- Main sync commit: `bd1e8d8b453b691a70e2ec9ba0c33446d5287baa`.
- Visible build: QH P.b 1.0.34.
- The separate fallback branch `backup/ota-on-dinh-1.0.30` remains untouched and continues to be the project checkpoint named **Cach update OTA on dinh**.


## CORRECTION: FW2.1 ECU confirmation false alarm

- The earlier report that FW2.1 could not confirm/connect to the ECU was a test setup mistake: the ECU itself was not plugged in.
- FW2.1 is NOT considered broken from that event.
- Keep QH FW2.1 as the active firmware line.
- The temporary FW2.2 recovery attempt was stopped and must not replace FW2.1.
- FW2.1 retains the two-pass >=8 KB Read All hardening introduced for residual BLE notification loss.
- Source restored to FW2.1 in commit `c949ef506fa45574ed5edea21fb4cc2c7ff498de`.
- Build workflow restored to FW2.1 in commit `742f83b32a4273dbf57ac27af6a315d970bb75c2`.
- Clean FW2.1 rebuild trigger: `0f592b31b2124ff7668605d3c01c8516c207e1bb`.


## iPhone notch / Dynamic Island home offset - QH P.b 1.0.35

- User feedback: on the QH home/dashboard, the QH ECU logo/header sat too close to the top edge and could be covered by the iPhone notch / Dynamic Island, while there was still unused space near the bottom.
- Fix is UI-only; no BLE/ECU/FW transport logic changed.
- Added `viewport-fit=cover` to the viewport meta tag so iOS/WKWebView exposes the real safe-area insets.
- QH dashboard top padding is now `max(24px, calc(env(safe-area-inset-top) + 8px))`.
- Dashboard bottom padding was reduced to `max(6px, env(safe-area-inset-bottom))` to reclaim the previous unused lower space and effectively move the whole home layout downward.
- Visible build bumped to QH P.b 1.0.35.
- Implementation commit: `9bf8a8952a834d4176ea349be94a728bce991e4d`.
