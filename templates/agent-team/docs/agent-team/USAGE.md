# Hướng dẫn sử dụng Agent Team (chi tiết)

**Phiên bản template:** xem `VERSION` ở root project (sau khi cài).  
**Đối tượng:** bạn (human) + Claude (orchestrator) + Grok CLI (coder).

Tài liệu này giải thích **cách xài từng ngày**. Quy tắc kỹ thuật đầy đủ: [WORKFLOW.md](./WORKFLOW.md). Hợp đồng ngắn: [AGENTS.md](../../AGENTS.md), [CLAUDE.md](../../CLAUDE.md), [GROK.md](../../GROK.md).

---

## 1. Đây là gì? (1 phút)

Agent Team là **quy trình làm feature trên disk**, không phụ thuộc chat nhớ gì:

| Ai | Việc |
|----|------|
| **Bạn** | Chọn size, duyệt spec/plan/list fix, quyết định product |
| **Claude** | **Chỉ** viết/review spec·plan·code, STATE/HANDOFF, gọi Grok — **không** implement product code |
| **Grok** | **Mọi** implement/fix product (kể cả **micro**) theo `HANDOFF.md` |

```text
Bạn nói việc
  → chọn size (micro | small | full)
  → Claude làm phần “nghĩ + soi”
  → Bạn chốt (khi path yêu cầu)
  → Grok code (small/full)
  → Claude soi code → (bug thì bạn chốt) → Grok fix
  → DONE
```

**Không** để Claude tự ship feature lớn khi Grok là coder.  
**Không** để Grok tự bịa requirement ngoài HANDOFF.

---

## 2. Cài vào project app (một lần)

### 2.1 Từ packaging repo (repo chứa `templates/agent-team/`)

```bash
# Project trống
./scripts/install-agent-team.sh /path/to/your-app --greenfield

# Project đã có code / CLAUDE.md / git
./scripts/install-agent-team.sh /path/to/your-app --brownfield

# Xem trước
./scripts/install-agent-team.sh /path/to/your-app --brownfield --dry-run
```

Auto: thư mục **trống** → greenfield; **đã có file** → brownfield.

### 2.2 Sau cài

```bash
cd /path/to/your-app
./scripts/verify-skeleton.sh
./scripts/test-guards.sh
```

**Brownfield:**

- Không ghi đè `CLAUDE.md` → có `CLAUDE.agent-team.md` → **merge** phần Agent-team orchestration vào `CLAUDE.md`.
- Không ghi đè `STATE.md` / `HANDOFF.md` đang chạy.
- `AGENTS.md` / `GROK.md` đã có → sidecar `*.agent-team.md` để merge tay.

### 2.3 Grok CLI

```bash
# Mặc định
export GROK_CMD="grok"

# Hoặc wrapper
cp scripts/grok-wrapper.example.sh scripts/grok-wrapper.sh
# sửa REAL_GROK / FLAGS trong file
export GROK_CMD="$(pwd)/scripts/grok-wrapper.sh"
```

Chạy `invoke-grok` **từ root project** (chỗ có `GROK.md` + `docs/agent-team/`).

### 2.4 Mở project bằng Claude Code

Claude đọc `CLAUDE.md` + `AGENTS.md` + `docs/agent-team/WORKFLOW.md`.  
Bạn chỉ cần nói việc + size (mục 4).

---

## 3. Bản đồ file (biết “sự thật” nằm đâu)

```text
your-app/
├── CLAUDE.md                 # Claude = orchestrator
├── AGENTS.md                 # Map chung Claude + Grok
├── GROK.md                   # Contract mỏng cho Grok
├── docs/
│   ├── specs/                # Spec đã viết
│   ├── plans/                # Plan đã viết
│   ├── reviews/
│   │   ├── spec/             # Review spec + plan (*-plan.md)
│   │   └── code/             # Review code từng iter
│   └── agent-team/
│       ├── STATE.md          # phase + size + gates (đang ở đâu)
│       ├── HANDOFF.md        # task Grok hiện tại
│       ├── WORKFLOW.md       # luật pipeline
│       ├── USAGE.md          # file này
│       └── templates/        # copy ra specs/plans/reviews
└── scripts/
    └── invoke-grok.sh        # cửa duy nhất gọi Grok (có preflight)
```

| Câu hỏi | Xem file |
|---------|----------|
| Đang phase nào? Size? | `docs/agent-team/STATE.md` |
| Grok được làm gì? | `docs/agent-team/HANDOFF.md` |
| Yêu cầu feature? | `docs/specs/...` |
| Cách implement? | `docs/plans/...` |
| Claude soi gì? | `docs/reviews/**` |

---

## 4. Bước 0 — Chọn size (bắt buộc mỗi task)

Nói rõ trong chat, ví dụ:

```text
size: small — thêm validate email trên form login
size: full — redesign checkout + payments
size: micro — sửa typo nút Submit
```

Claude ghi `size:` vào `STATE.md`.

| Size | Khi nào dùng | Đi những bước |
|------|----------------|---------------|
| **micro** | Typo / vài dòng trivial | HANDOFF mỏng → **Grok** (`invoke-grok`); gate pre-code = `n/a`. Claude **không** code. |
| **small** | Feature/bug nhỏ, ít file, scope rõ | Spec ngắn → Claude review sạch → **bạn OK** → Grok → code review → (bug → **bạn OK** → Grok fix). Plan **tuỳ chọn**. |
| **full** | Nhiều module, schema/API/auth, rủi ro cao, scope mơ hồ | Full: spec ⟲ → bạn → plan ⟲ → bạn → Grok → code ⟲ |

**Default** nếu bạn không nói: Claude đề xuất (thường `small`) hoặc hỏi bạn.

**Upgrade size** nếu việc hóa ra lớn hơn (micro → small/full). Không được dùng micro để lách feature thật.

---

## 5. Flow chi tiết theo size

### 5.1 `micro` — siêu ngắn (vẫn Grok code)

```text
Bạn: "micro — đổi chữ button Cancel thành Hủy"
Claude: set size=micro, gates pre-code = n/a
        viết HANDOFF mỏng (goal + file + verify)
        ./scripts/invoke-grok.sh
Grok: sửa code + verify
Claude: (tuỳ) code review nhanh → DONE
```

**Bạn không cần** approve spec/plan.  
**Vẫn chạy** `./scripts/invoke-grok.sh` — Claude **không** tự patch product code.

---

### 5.2 `small` — xương sống (dùng nhiều nhất)

```text
0. size: small (+ slug feature)
1. Claude viết SPEC ngắn     → docs/specs/YYYY-MM-DD-<slug>-spec.md
2. Claude REVIEW spec        → docs/reviews/spec/...
   còn bug critical/high/medium? → sửa spec → review lại (tối đa 10 vòng)
3. WAIT_HUMAN_SPEC           → Claude DỪNG, đưa path cho bạn
4. Bạn: "approve" / "sửa …"
5. (Optional) PLAN nếu cần; không thì plan_review=n/a, human_plan=n/a
6. Claude ghi HANDOFF + STATE phase=CODE, iteration=1
7. ./scripts/invoke-grok.sh  → Grok code + verify
8. Claude CODE REVIEW
   - sạch → DONE
   - có bug → WAIT_HUMAN_CODE_FIX → bạn approve list fix
             → HANDOFF chỉ findings → Grok fix → review lại (tối đa 10 vòng)
```

**Câu bạn nói sau khi đọc spec:**

- `approve` / `ok spec` / `được, làm tiếp`
- `changes: …` (Claude sửa + review lại, rồi mới chờ bạn lần nữa)

**Câu sau code review có bug:**

- `approve fix` / `ok fix C1 C2`
- `đừng fix C3, deferred` / `đổi approach …`

---

### 5.3 `full` — đủ nghi thức

```text
0. size: full
1. SPEC draft → Claude SPEC_REVIEW ⟲ sạch (≤10)
2. WAIT_HUMAN_SPEC → bạn approve
3. PLAN draft → Claude PLAN_REVIEW ⟲ sạch (≤10)
4. WAIT_HUMAN_PLAN → bạn approve
5. HANDOFF + invoke-grok (iter 1)
6. CODE_REVIEW
   - sạch → DONE
   - bug → WAIT_HUMAN_CODE_FIX → bạn → Grok fix ⟲ (≤10) → DONE
```

Giống small nhưng **bắt buộc** có plan + review plan + human approve plan trước Grok.

---

## 6. Vai trò “bạn” — khi nào phải trả lời

Claude **bắt buộc dừng** và chờ bạn khi:

| Phase | Bạn cần làm |
|-------|-------------|
| `WAIT_HUMAN_SPEC` | Đọc spec + review Claude; approve hoặc yêu cầu sửa |
| `WAIT_HUMAN_PLAN` | (full, hoặc small có plan) Đọc plan + review; approve/sửa |
| `WAIT_HUMAN_CODE_FIX` | Đọc findings code; approve cho Grok fix hoặc đổi hướng |

**Không** giả định “im lặng = đồng ý”.  
Nếu bạn chưa approve, Claude **không** được gọi Grok / sang phase tiếp.

---

## 7. Bug “chặn” là gì?

Trong mọi review (spec / plan / code):

| Severity | Ảnh hưởng |
|----------|-----------|
| **critical / high / medium** | **Chặn** — phải sửa, re-review (hoặc bạn chủ động deferred có lý do) |
| **low / nit** | Mặc định `deferred` — **không** chặn DONE / advance |

Verdict Claude:

- `CHANGES_REQUESTED` hoặc còn open blocking → chưa được `gates.*_review: approved`
- `APPROVED` + 0 open blocking → mới được sang WAIT_HUMAN_* (spec/plan) hoặc DONE (code)

---

## 8. Cách làm việc với Claude (prompt mẫu)

### Bắt đầu feature

```text
size: small
Feature: export CSV danh sách orders trong admin.
Constraint: chỉ role admin; max 10k rows; dùng query hiện có.
```

```text
size: full
Thiết kế lại checkout: multi-step, lưu draft, Stripe.
```

```text
size: micro
Sửa typo "Sucess" → "Success" trong toast.
```

### Khi Claude dừng chờ bạn

```text
approve
```

```text
approve spec. Làm tiếp.
```

```text
changes requested:
- non-goal: không làm realtime export
- success criteria: thêm test empty list
```

```text
approve fix cho C1, C2. C3 deferred.
```

### Khi muốn Grok chạy (thường Claude tự chạy sau khi gate đủ)

Bạn có thể nhắc:

```text
Gates đã ok. Chạy ./scripts/invoke-grok.sh
```

Hoặc tự chạy trong terminal project root:

```bash
./scripts/invoke-grok.sh
# thêm note ngắn (optional):
./scripts/invoke-grok.sh "Prefer existing OrderQuery service"
```

---

## 9. HANDOFF & Grok (small/full)

### 9.1 Claude chuẩn bị HANDOFF

File: `docs/agent-team/HANDOFF.md` (template: `templates/HANDOFF.template.md`).

Bắt buộc có:

- Feature slug, Iteration, STATE phase = `CODE`
- Goal + success criteria
- Links: spec, plan (nếu có), latest review (iter > 1)
- In scope / out of scope
- Verify commands **thật** (`npm test`, `pytest`, … — không `true` trừ smoke)
- `## Grok result` chỉ còn dòng `pending` trước mỗi lần invoke
- Iter > 1: bảng **Open findings** chỉ bug chưa fix

### 9.2 Preflight (script từ chối nếu sai)

`invoke-grok.sh` fail nếu:

- `size` là `micro` / `null`
- phase ≠ `CODE` (STATE và HANDOFF)
- slug / iteration lệch
- thiếu approve: `human_spec`, `spec_review` (+ plan gates theo size)
- iter ≥ 2 mà `human_code_fix` chưa approved
- Grok result còn pass/fail / không có dòng chỉ `pending`

Sửa STATE/HANDOFF theo message lỗi, rồi chạy lại.

### 9.3 Grok xong

Grok cập nhật `## Grok result` (pass/fail + lệnh đã chạy).  
Claude đọc result → CODE_REVIEW → tiếp pipeline.

---

## 10. STATE.md — đọc nhanh “đang ở đâu”

Ví dụ đang chờ bạn duyệt spec:

```yaml
feature: orders-csv-export
size: small
phase: WAIT_HUMAN_SPEC
iteration: 0
spec: docs/specs/2026-07-20-orders-csv-export-spec.md
gates:
  human_spec: pending
  human_plan: n/a
  human_code_fix: n/a
  spec_review: approved
  plan_review: n/a
  code_review: pending
```

Ví dụ sẵn sàng Grok lần 1 (small, không plan):

```yaml
phase: CODE
iteration: 1
size: small
gates:
  human_spec: approved
  human_plan: n/a
  spec_review: approved
  plan_review: n/a
  human_code_fix: n/a
```

Ví dụ chờ bạn cho Grok fix:

```yaml
phase: WAIT_HUMAN_CODE_FIX
iteration: 1
latest_code_review: docs/reviews/code/2026-07-20-orders-csv-export-iter-1.md
gates:
  code_review: open
  human_code_fix: pending
```

---

## 11. Giới hạn vòng lặp

| Vòng | Tối đa | Quá thì |
|------|--------|---------|
| Spec author ↔ review | 10 | `blockers` + hỏi bạn |
| Plan author ↔ review | 10 | `blockers` + hỏi bạn |
| Code fix ↔ review | 10 | `blockers` + hỏi bạn (không auto Grok) |

---

## 12. Checklist một feature `small` (in ra dùng)

- [ ] Nói `size: small` + mô tả feature  
- [ ] Có file spec trong `docs/specs/`  
- [ ] Có review spec `APPROVED`, 0 blocking open  
- [ ] `STATE.phase = WAIT_HUMAN_SPEC` → **bạn đã approve**  
- [ ] Plan: có file + review **hoặc** `plan_review`/`human_plan` = `n/a`  
- [ ] HANDOFF đầy đủ, `## Grok result` = `pending`  
- [ ] `./scripts/invoke-grok.sh` pass preflight + Grok xong  
- [ ] Code review: sạch → DONE; còn bug → bạn approve fix → Grok → review lại  
- [ ] `STATE.phase = DONE`  

---

## 13. Checklist `full` (thêm so với small)

- [ ] Plan file + plan review `APPROVED`  
- [ ] `WAIT_HUMAN_PLAN` → bạn approve  
- [ ] Không được `plan_review: n/a`  

---

## 14. Lỗi thường gặp

| Triệu chứng | Nguyên nhân | Cách xử |
|-------------|-------------|---------|
| Claude tự sửa product code | Sai role (Claude chỉ spec/plan/review) | Nhắc HANDOFF + `invoke-grok`; kể cả micro |
| `human_plan must be approved` (full) | Chưa duyệt plan | Chờ/ghi `human_plan: approved` |
| `human_code_fix must be approved` | Iter ≥ 2 chưa bạn OK fix | Approve findings trước |
| `## Grok result must be pending` | Còn pass/fail cũ | Xóa body, chỉ để `pending` |
| `feature mismatch` | STATE slug ≠ HANDOFF | Đồng bộ slug |
| Claude tự code feature | Sai role | Nhắc HANDOFF + invoke-grok; đọc CLAUDE.md |
| Claude nhảy PLAN khi bạn chưa OK | Bỏ WAIT_HUMAN | Nhắc dừng; không approve giả |
| Spec lởm đã CODE | Bỏ Claude review | Bắt review-until-clean trước human |

---

## 15. Nâng cấp template sau này

Từ packaging repo:

```bash
./scripts/install-agent-team.sh /path/to/your-app --brownfield
```

- Scripts + docs template được refresh  
- **STATE/HANDOFF hiện tại được giữ**  
- Merge lại `CLAUDE.agent-team.md` nếu contract orchestrator đổi  

Rồi:

```bash
cd /path/to/your-app && ./scripts/verify-skeleton.sh && ./scripts/test-guards.sh
```

---

## 16. Demo học file mẫu

Xem cấu trúc artifact (size **full** giả lập):

`docs/agent-team/examples/demo-feature/`

Đọc theo thứ tự README trong thư mục đó. **Không** copy demo thành STATE live — làm feature thật từ `templates/`.

---

## 17. Tóm tắt “chỉ cần nhớ”

1. **Size** trước: `micro` | `small` | `full`  
2. **Claude** = spec / plan / review / HANDOFF — **không** product-code  
3. **Grok** = mọi CODE (kể cả micro) qua **`./scripts/invoke-grok.sh`**  
4. **small/full:** Claude soi spec/plan sạch → **bạn chốt** → Grok  
5. Code bug: Claude soi → **bạn chốt fix** → Grok fix  
6. Sự thật trên **disk** (`STATE`, `HANDOFF`, specs, plans, reviews)

---

## 18. Tài liệu liên quan

| File | Nội dung |
|------|----------|
| [WORKFLOW.md](./WORKFLOW.md) | Pipeline + sizing + preflight |
| [STATE.md](./STATE.md) | Enum phase/gates + size |
| [README.md](./README.md) | Install + daily loop ngắn |
| [SUPERPOWERS-INTEGRATION.md](./SUPERPOWERS-INTEGRATION.md) | Nếu dùng Superpowers |
| [ECC-INTEGRATION.md](./ECC-INTEGRATION.md) | Nếu dùng ECC |
| `../../CLAUDE.md` | Duty orchestrator |
| `../../GROK.md` | Duty coder |
| `../../AGENTS.md` | Map chung |

---

*Hết hướng dẫn. Bắt đầu bằng một task `size: small` trên feature thật nhỏ để quen nhịp dừng–approve–Grok.*
