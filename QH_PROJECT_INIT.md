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
