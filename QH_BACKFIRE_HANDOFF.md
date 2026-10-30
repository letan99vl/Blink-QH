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


## QH 1.2.14 — V11 LV1 MIN NEGATIVE PREVIEW + two auxiliary cells exact 1 (2026-10-30)
- User requested V11 one Backfire level at its most-negative possible ignition value. The existing V11 byte codec is `decMainIgn(raw) = round1((raw-64)*0.28125)`, therefore raw 0 = **−18.0 degrees**. Mathematical coding proof ONLY, not hardware/engine validation. Note: raw zero is the codec edge; don't assume ECU runtime treats it safely.
- New `backfireCapabilities()` reports V11 **LV1 −18.0° (raw 0), PREVIEW ONLY**, while **LV2 and LV3 remain disabled** and supported=false. Frontend QH P.b 1.2.14 displays this LV1 preview, RPM max 6000 unverified, and keeps BACKFIRE START/RESTORE/EXPORT/IMPORT unsafe writes disabled. Classic V9/V10/Ultra Pro1 original level rules are unchanged. All ECU programming APIs still fail closed on V11.
- Read-only V11 diagnosis also decodes all three PAGE6 group-4 RPM-like fields (each at group*4+3) without selecting any as the **real rev limiter**. True RPM-limit group and serializer must be independently proven from original V11 PC executable and real ECU readback before any automatic limit write. Do not assume 42B page6 hint is Ultra Pro1 proof, and do not force V11 to V10.
- User correction on additional **two cells**: BOTH targets are the exact numeric value **1**, NOT 50% of their present value, NOT a half-scale and NOT a percentage. The available user-image attachment in this turn appears to show an older TPS error overlay, not clearly labeled two editable cells. Their feature names, bank, row/column/byte offsets, encoding, baseline, readback and rollback are **NOT identified**. Protocol records `extraCellRequest:{count:2,exactValue:1,coordinatesVerified:false,writeAvailable:false}`; no payload is changed, no guessed address/writer. If a later screenshot or the original software identifies them, add explicit byte-safe read/patch/write/verify/restore for both.
- Existing safe 28-cell ign-byte preserve+readback and global backup/rollback design remain. To activate all-in-one Backfire: verify V11 raw 0 ECU semantics; identify actual RPM LIMIT and represent 6000; identify both extra cells and their value=1 codecs; verify old data capture and exact restoration; bench test on real ECU, engine OFF. Keep BACKFIRE programming disabled on V11 until ALL pass.
- Pre-change backup branches in source/public: `backup/pre-qh-1.2.14-v11-one-level-preview`. Source: protocol commits d37598b310310621d0860296daf80dcbde8714d7 / 3deea672093a38bfefedc8ba7b0a57afd35aab8e; index commits 57c85ebdb9d6dec1567cc715ba2dc0f80445388d / 8583e643ddb1f9bcdeafd6b58ace8b3a029475c2 / 988661323c77782d2c904b7793b3a04fade8c63c. QA test updated to 1.2.14 with preview and extra targets and write-gate checks.

## QH P.b 1.2.15 — V11 Backfire IGN TIME 5500/6000 = 1 ms (READ-ONLY CHECKPOINT, 2026-10-30)
- User confirmed EXACT additional cells: **IGN TIME (DWELL/BOBIN)** at RPM **5500** and **6000**, both desired **1 ms (fixed absolute values; not 50%)**. User also wants V11 LV1 -18deg at all TPS rows for both RPM columns and rev limit 6000. No requirement to change any other dwell columns.
- Proven implementation encoding: V11 page4 is a 30-byte, 1x30 IGN TIME map; `encMainDwell(1)=20`, `decMainDwell(20)=1.00 ms`. Classic profiles `encMainDwell(1)=16`, `decMainDwell(16)=1.02 ms` due to quantization. Current 5500/6000 column indices must be matched to ECU's live published RPM axis, never hardcoded or guessed. V11 -18.0deg maps to raw=0 mathematically, but hardware behavior is not confirmed.
- QH 1.2.15 now **read-only** inspects PAGE6 (RPM-looking groups), PAGE3 (420 IGN bytes), PAGE4 (30 dwell bytes) per selected MAP; displays current ms/raw values for 5500 and 6000 where ECU axes match, plus target raw20 at 1ms. No invented V11 RPM LIMIT byte; no write permission is granted by this readback.
- Initial attempt to extend the three-table transaction (28 IGN cells, two dwell cells, RPM limit) was intentionally ROLLED BACK to pre-1.2.15 working code: incomplete write/rollback code must NOT ship. Private commits for reverted experimental modifications: 0cac538b6ddbcd24b106fce4bf00cede71fb2daa, 96fbe4568e421a742ab4e78269c9cd16332308e1, 112c080d1529b8751052779ed31756a5bdd4e2d2. Rollback commits b1cb9d1acfc6cc8838728467b708a78de6cac003, 43d16355bf555583a65a9e336a59f3d564919306. Backup branch `backup/pre-qh-1.2.15-backfire-ign-time-1ms` in both repositories.
- **IMPORTANT LIMITATION**: In 1.2.15, Backfire START on classic V9/V10/Ultra1 retains its existing two-table behavior (28 IGN + RPM LIMIT) and DOES NOT automatically set IGN TIME to 1ms. V11/Ultra Pro2 Backfire START remains disabled. The visible UI explicitly identifies the new IGN TIME request as a diagnostic/target only.
- Prerequisites before V11 Backfire writing is safe: identify REAL rev limiter field for V11 PAGE6 in original application, demonstrate exact 6000 RPM scaling and safe readback; confirm raw0 ignition edge is accepted/used as -18deg on real ECU; implement V2 identity-tied raw backup of ALL 420 IGN bytes + 30 dwell bytes + full PAGE6 limiter baseline, three-step atomic write with ACK/whole-page verification and rollback, preserve every other byte, run physical ECU engine-OFF bench testing. Do not infer rev limiter from any of PAGE6's three RPM/64-style bytes.
- QH Web UI Regression run `41028790697` completed SUCCESS (all old checks plus updated `check-qh-backfire-inspect.js` verifying three read-only page reads, V11 target raw20, write guards, 5500/6000 axes). This proves STATIC simulated checks only; no real ECU bench test.

## QH P.b 1.2.16 — LIVE Backfire now includes 2× IGN TIME for already-supported classic ECU (2026-10-30)
- User supplied screenshot of restored Backfire, LV1 -19°, original 9000rpm, main IGN TIME codec ~1.02ms/raw16 and insisted the 5500/6000 RPM cells must actually be written, not only displayed. Target values are absolute 1ms each, NEVER 50% reduction. The existing V9.1X, V9.2, V10.2 and REDLEO Ultra Pro1 Backfire flow gains these two fields; V11/Ultra Pro2 automatic Backfire remains locked pending hardware validation.
- Original ECU map of IGN TIME is PAGE4 selected bank, 1 row × 30 raw bytes. Two columns are derived from ECU-published RPM axes and matched EXACTLY to 5500 and 6000 RPM. Typical classic rounding `encMainDwell(1)=16`, `decMainDwell(16)≈1.02ms` (no false claim of exactly 1.00ms); V11 1.00ms maps to raw20 but is still read-only for Backfire.
- Added `backfireWriteDwellPatch(bank,patches)`: checks known original profile, mainWrite permission, exactly two distinct valid columns, expected raw bytes from fresh PAGE4 read, preserves all other 28 PAGE4 bytes and reply-only tail, transmits exact 30B payload using the existing checksum/ACK and prefix/tail validation, then independently READBACK-verifies all 30 bytes. No-op avoids redundant write. A V11/unknown profile cannot call this writer.
- Backfire BẮT ĐẦU sequence on supported ECU: ignition 420B + dwell 30B + RPM original PAGE6 read; save `QH-BACKFIRE-BACKUP-V2` under the existing identity-and-MAP-specific `qhBackfireSnapshotV1:` key (do not orphan old backups); require saved backup to read back; write 28 IGN raw cells → write 2 IGN TIME raw cells → write RPM limit 6000; verify 420+30 and limit. A failed step marks `needs_restore` and attempts best-effort rollback, retaining backup and PARTIAL warning if hardware/transport prevents proof.
- DÙNG MAP GỐC restores original 28 IGN cells and the **two original raw IGN TIME bytes**, then original limiter RPM; preserves all 392 other IGN and 28 other IGN TIME raw cells; refuses to overwrite untracked edits; compares complete applicable readback before confirming. Old `QH-BACKFIRE-BACKUP-V1` remains importable/restorable for its older 28IGN+RPM scope but has no recorded dwell values and must not claim dwell restoration.
- UI text now states V9/V10/Ultra1 Backfire will write + restore IGN TIME and shows quantized actual 1.02ms. V11 continues PREVIEW LV1 -18°/raw0 and READ-ONLY PAGE3/PAGE4/PAGE6; all V11 Backfire writes blocked, because PAGE6 true limiter field and raw0 physical behavior remain unverified.
- Pre-change backup branches: `backup/pre-qh-1.2.16-backfire-dwell-restore` in source and public repos. Source QH Web UI Regression run `41030198974` completed SUCCESS: existing controls, JS syntax, TPS, V11 read-only and new `tools/check-qh-backfire-dwell.js` simulated 2-byte patch, exact 28 unaffected bytes and tail, stale raw rejection, V11 write lock, V1/V2 schema, status conditions, rollback and outside-edit rejection.
- The separate legacy `Check REDLEO Protocol JS` workflow has an older unrelated test failure at `tools/check-row-orientation.js` (expects generation-aware compensation wording). This failure predates 1.2.16 and was not counted as a pass. A passing offline test is NOT actual motorcycle/ECU bench validation. First real verification must use engine OFF, ignition ON, stable BLE, separately exported original map; review PAGE3/PAGE4/PAGE6 before + after and DÙNG MAP GỐC. Repeated pops at strongly negative timing and low bobin dwell can cause exhaust fire, misfires and engine/coil damage.
