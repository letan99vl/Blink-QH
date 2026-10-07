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
