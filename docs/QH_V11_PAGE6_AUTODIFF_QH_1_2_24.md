# QH ECU 1.2.24 - V11 / Ultra Pro2 PAGE6 diagnostic (READ-ONLY)

## Why
The QH app can edit ATE V11 / Ultra Pro2 Idle/Limit PAGE6. However the same ECU's native PAGE6 has three RPM-like values (G1/G2/G3) and QH does not yet have independent proof which group controls the actual engine rev limiter for a given ECU. This release adds a baseline/diff diagnostic instead of silently assuming a group or enabling automatic Backfire.

## Confirmed protocol structure
- Read the selected bank's PAGE6 via existing `readIdlePageReal` / `readMaxSpeedFromIdle`. Minimum direct data length: 43 bytes.
- 12 bytes: 4 Idle/Limit rows for each of three groups G1/G2/G3, transmitted group-major.
- 9 bytes: AutoShift.
- 22 bytes: ECT Motor.
- RPM-like row 4: zero-based offsets **3**, **7**, **11**.
- Decode as current QH V11 editor: `Math.round(raw*64/50)*50`; encode in protocol: `Math.round(RPM/64)`.
- The offset only proves where the serialized GUI value lives. It does **not** prove that changing it changes the physical engine limiter.

## Implementation
- `redleo_real_protocol.js`: after successful V11 `readIdlePageReal`, best-effort `QHV11Page6Diag.recordRead`. After V11 `writeV11IdleLimit` successfully verifies PAGE6 via `writeWritablePrefixPage`, use the verified `pageCache` readback to call `recordWrite`. Diagnostics never change the ECU write result and never send an extra write.
- `index.html`: inline `diagnostics/qh_v11_page6_diff_v124.js` inside the existing Backfire V11 section; stores localStorage `qhV11Page6DiffV1:<identity>:MAP<bank>`.
- First successful read saves a baseline once per ECU/MAP; subsequent reads compare with the saved baseline. Verified Idle/Limit writes log a before/after pair, preserved through a repeated same-byte follow-up read.
- A sole changed byte at exactly one of 3,7,11 becomes `candidateGroup`, but `physicalLimiterVerified:false`. Multiple changed bytes, invalid frame, different length, or another offset must not be labeled a confirmed limiter.
- UI: **GÓC ĐÁNH LỬA → BACKFIRE → V11/Ultra Pro2 → CHẨN ĐOÁN PAGE6**. Buttons **LƯU MỐC PAGE6**, **ĐỌC & SO SÁNH**, **XUẤT JSON PAGE6**.
- Replacing an existing baseline requires a confirmation. Separate storage per authenticated ECU/MAP, with strict byte-range and format validation.
- No V11 Backfire automatic limit writer is enabled. The pre-existing V11 MAP-only trial remains independent.

## Usage / bench evidence
1. With ECU connected and stable, select the MAP and use **ĐỌC IDLE TỪ ECU (PAGE6)** before any changes. This stores the baseline.
2. In QH's native 4×3 Idle/Limit editor, change only the setting that you have independently shown to have the expected limiter effect, and write it to ECU. The existing verified PAGE6 writer logs before/after automatically.
3. Open the diagnostic UI and **XUẤT JSON PAGE6**. Review `lastComparison`, `changes`, `candidateGroup`, `baseline`, `lastSeen`.
4. Restore the original tuning and verify readback. Do not test on a moving vehicle or use automatic Blackfire while group identity remains unverified.

## QA status
- JS parse/compile checks on full inline Backfire controller and protocol: PASS.
- Mock tests: G1, G2, G3 byte offsets; one-byte vs multi-byte, altered length, invalid byte, retained write-readback record, ECU/MAP-specific storage; all PASS.
- No real V11/Ultra Pro2 ECU hardware test yet; physically effective limiter group remains UNKNOWN. No automatic Backfire V11 enabling in this release.
