# QH ECU 1.1.18 — BACKFIRE GA THÒNG / BÀN GIAO

## Phạm vi yêu cầu đã chốt
- Giao diện **Full → Góc đánh lửa → BACKFIRE**.
- Thay đổi đúng **hai breakpoint RPM = 5500 và 6000**, **mọi hàng TPS từ 100% đến hàng thấp nhất/IDLE**: 14 × 2 = **28 ô** (không phải 14 ô, không phải dừng ở TPS 30%).
- 3 mức do người dùng yêu cầu: LV1 −19°, LV2 −21°, LV3 −23°; giới hạn tua 6000 RPM.
- Bản gốc lưu riêng theo định danh handshake ECU + profile + map bank + thông số gốc; có xuất/nhập backup JSON.
- Đã có tự **đọc và so sánh thực tế** IGN + RPM mỗi lần mở lại/kết nối Full (khi máy dừng, LIVE mới), nút BACKFIRE sáng chỉ khi kiểm chứng đầy đủ. Không tự ghi khi khởi động app.
- DÙNG MAP GỐC khôi phục đúng 28 byte IGN và limiter gốc, giữ 392 ô còn lại.

## Hỗ trợ mã hóa phải tuân thủ
- V9.1X / V9.2 / V10.2 / Ultra Pro1 dùng main IGN byte center +64, 360/1024 độ mỗi raw-step, byte [0..255].
- Round trip đã kiểm tra: LV1 −19° → raw 10 → −19.0°; LV2 −21° → raw 4 → khoảng −21.1°.
- LV3 −23° sẽ bị ép byte 0 → −22.5°. **KHÓA LV3** (không âm thầm ghi sai giá trị).
- ATE V11 / Ultra Pro2 dùng center +64, 0.28125°/raw-step, biên âm −18°. **KHÓA toàn bộ ba LV yêu cầu**.
- V8 / profile chưa chứng minh serializer limiter: KHÓA. Không tự sử dụng page6 đời khác.

## Protocol: redleo_real_protocol.js
Các API mới trên window.BlinkRealProtocol:
- \`backfireCapabilities()\`: kiểm tra profile và mã hóa góc lửa từng LV.
- \`backfireReadLimiter(bank)\`: đọc giới hạn RPM từ PAGE6 đã xác minh serializer riêng.
- \`backfireWriteLimiter(bank,targetRpm,expectedCurrentRpm)\`: đọc lại baseline, cập nhật đúng 2 byte RPM trong writable payload, ACK + READBACK, các byte khác phải bất biến.
- \`backfireWriteIgnPatch(bank, patches)\`: bắt buộc đúng **28 entries**, đủ 14 hàng × 2 cột RPM 5500/6000; kiểm tra expectedRaw từng ô, vá đúng 28 raw bytes trên PAGE3; 392 byte khác giữ y nguyên; READBACK xác minh toàn 420 byte.
- V9.1x PAGE6: 30B, maxSpeed offset byte 4; V9.2: 62B, offset 4; V10.2: 18B, offset 4; Ultra Pro1: 42B, offset 6.
- IGN wire rows đảo ngược: index = \`(13 - uiRow)*30 + col\`. Thao tác chỉ bắt đầu sau khi đọc đủ raw PAGE3 và PAGE6.

## UI: index.html
- Nút trạng thái mới chỉ xuất hiện ở Full / Góc đánh lửa, có panel lựa chọn LV, SOI ECU, BẮT ĐẦU BACKFIRE, DÙNG MAP GỐC, XUẤT/ NHẬP backup JSON.
- Trước khi ghi: ECU kết nối LIVE, bản tin RPM tươi (<= 4,5 giây), RPM <= 100, không OTA / recording / thao tác ECU khác; xác nhận rõ ràng và backup trước mọi write.
- Backup app-local: tiền tố \`qhBackfireSnapshotV1:\`, chứa bản IGN đã decode, raw 420B, RPM gốc, map bank, ID ECU, hai vị trí cột. Dữ liệu **không nằm trong tệp APK/IPA**; có thể bị mất nếu xóa app/data, cần xuất JSON.
- Đổi ON: lưu pending → ghi 28 byte IGN → ghi limiter → đọc lại IGN + limiter → báo ON. Nếu một bước lỗi sẽ thử khôi phục; nếu không chắc phải báo PARTIAL, giữ backup, không cho chạy máy.
- Đổi OFF: chỉ khôi phục 28 byte gốc và RPM gốc, không sửa các byte ngoài vùng. Nếu 392 byte ngoài vùng đã thay đổi hoặc RPM bị chỉnh bên ngoài, chặn để tránh đè map khác.
- Nếu không có backup mà thấy 28 ô và 6000rpm khớp LV: chỉ hiện **NGHI BACKFIRE**, KHÔNG hiện ON và KHÔNG hứa khôi phục.
- UI normal write IGN/Idle làm vô hiệu trạng thái cũ và yêu cầu SOI ECU lại; tránh đèn ON giả.

## Kết quả QA và còn lại
- Mã JS ở cả 13 script inline và protocol đã kiểm tra syntax.
- Kiểm tra codec thuần cho V9/V10/V11: LV1/2 chỉ tương thích classic; LV3 và mọi LV V11 bị chặn.
- Mô phỏng byte patch với baseline 420B: đúng 28 bytes đổi, toàn 392 bytes khác bất biến; restore bit-for-bit.
- **Chưa kiểm thử trên ECU/xe thật.** Cần xác nhận thực tế từng đời ECU ở trạng thái máy dừng, trên bệ thử, với backup độc lập. Không coi cú pháp/giả lập là xác nhận phần cứng.
- Backfire tại TPS 100% có nguy cơ hư động cơ, cổ pô, bầu xúc tác và cháy nổ ở đường xả. Không sử dụng trên đường công cộng.

Để tiếp tục, ưu tiên thử READBACK thực trên V9.2, sau đó V10.2/Ultra Pro1. Không mở V11/LV3 nếu chưa chứng minh bộ mã hóa ECU có thể biểu diễn đúng giá trị yêu cầu.


## QH P.b 1.2.13 — Backfire KIỂM TRA read-only on Ultra / V11 (2026-10-30)
- Real report: Ultra ECU in QH showed Backfire KIỂM TRA button disabled. Root cause in index.html Backfire controller: qhBfCheck was disabled by the same `!caps.supported` gate used to block 28-cell IGN + RPM writes. MODERN_V11 has no verified Backfire writer for LV1 −19°, LV2 −21°, LV3 −23°; disabled check was poor UX, not proof that Ultra hardware is unsupported.
- Separate manual read-only KIỂM TRA permission from write permission. When connected LIVE on Góc đánh lửa, the button is enabled regardless of `caps.supported`; for supported V9/V10/Ultra Pro1, keep existing full readback and ON/OFF comparison. On V11/Ultra Pro2, run `backfireInspectReadOnly(bank)` and report genuine handshake ident/firmware, current-bank PAGE6 byte length and IGN byte length. PAGE6 42B is only a hint to investigate mistaken Ultra Pro1/V11 classification, never permission to switch serializer automatically. Unknown/V8 show diagnostic info without writes.
- Protocol probe uses `readDirectPageReal` for page6 and page3 only. No ECU writes, no forced Ultra identity, no limiter offset invented from V11 (whose page6 is 43B and unlike classic ECU). No automatic read-only background loop on unsupported models.
- Existing `context()`, `backfireWriteLimiter`, `backfireWriteIgnPatch`, `qhBfStart` and Restore safety gates remain intact. LV1/2 remain supported ONLY for proven classic V9/V10/Ultra Pro1 writers; LV3 remains locked; all three LV remain locked for V11/Ultra Pro2 pending true hardware + codec validation. Do not enable V11 writes merely to satisfy UI.
- Private implementation: protocol commit d8d834565841d821ab0a45889cc0d1f7ec6ad67c, index commit bb7234a6409579534de0067e38dfa80529236d6f, test commit 42c3b880b39fe3b55ca9c0faa131e944a6d7f1ca, workflow commit 5a8510e303ce390d3a0603c25071344c607f1bc8.
- Public release: protocol commit bd7eebd686c38275d514b1d3964f69ed0bdbb625, index commit 4472afffe12bd9c614a82d9d39a1dbcb13bba423. Source/public matching blob SHAs: protocol 0bc661f76cd61bf1cee1b27033ac9909cb1924e7, index 8343f9290eb8673f2af0995b0287d83887375e1c. Backup branches `backup/pre-qh-1.2.13-backfire-check-ultra-diagnostic` in both repos.
- QH Web UI Regression run 41025785809 completed SUCCESS (includes new `tools/check-qh-backfire-inspect.js`, script parsing, protocol syntax, old map control/TPS checks). This is STATIC / simulated, not proof of actual ECU readback on phone.
- Public runtime: https://letan99vl.github.io/Blink-QH/?v=1.2.13. No ESP32 FW, OTA, Android APK, or iOS IPA change. Next hardware check: engine OFF, ignition ON; connect QH, enter GÓC ĐÁNH LỬA > BACKFIRE > KIỂM TRA; record displayed ID/FW/PAGE6/IGN, compare against REDLEO Ultra PC original software. Do not run or write Backfire until the ECU family is confidently established and its write path independently validated.
