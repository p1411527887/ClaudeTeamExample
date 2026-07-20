# Template Agent Team

**Phiên bản:** xem [`VERSION`](../../VERSION) · **Changelog:** [`CHANGELOG.md`](../../CHANGELOG.md)

Workflow multi-agent trên disk: **Claude điều phối**, **Grok code** qua CLI, SSOT (spec / plan / reviews / HANDOFF / STATE).

> **Vai trò CLAUDE.md**  
> - *Repo packaging* root `CLAUDE.md` = chỉ Karpathy.  
> - *Sau khi cài vào app*, `CLAUDE.md` = contract orchestrator (Karpathy + agent-team).

**Hướng dẫn xài chi tiết:** [USAGE.md](./USAGE.md)

---

## Bạn đang ở đâu?

| Bạn ở… | Làm gì |
|--------|--------|
| **Repo packaging** (có thư mục `templates/agent-team/` ở root) | Cài bằng lệnh bên dưới, chạy từ **root packaging**. |
| **Project app** (file này là `docs/agent-team/README.md`) | Skeleton đã cài. Đọc [USAGE.md](./USAGE.md), rồi [Vòng lặp hàng ngày](#vòng-lặp-hàng-ngày-ngắn). **Không** chạy lại lệnh install packaging. |

Lệnh chỉ dùng ở packaging (path dạng text, không phải link markdown tương đối — vẫn đúng sau khi copy):

```bash
./scripts/install-agent-team.sh /path/to/your-project
```

Path kiểu `templates/agent-team/...` chỉ có nghĩa từ root packaging.

---

## Cài từ repo packaging (khuyên dùng)

Từ **root packaging**:

```bash
# auto: thư mục trống → greenfield; đã có file → brownfield
./scripts/install-agent-team.sh /path/to/your-project

# full copy — từ chối dest không trống trừ --force
./scripts/install-agent-team.sh /path/to/your-project --greenfield
./scripts/install-agent-team.sh /path/to/your-project --greenfield --force

# project có sẵn: copy chọn lọc; không đè CLAUDE.md, STATE.md, HANDOFF.md
./scripts/install-agent-team.sh /path/to/your-project --brownfield

# xem trước
./scripts/install-agent-team.sh /path/to/your-project --brownfield --dry-run
```

**An toàn brownfield:** refresh script/docs template nhưng **giữ** `STATE.md` / `HANDOFF.md`. Nếu app đã có `VERSION` / `CHANGELOG.md` → sidecar `VERSION.agent-team` / `CHANGELOG.agent-team.md`.

Rồi:

```bash
cd /path/to/your-project
./scripts/verify-skeleton.sh
./scripts/test-guards.sh
```

### Greenfield thủ công (chỉ packaging)

```bash
rsync -a --dry-run templates/agent-team/ /path/to/your-project/
rsync -a templates/agent-team/ /path/to/your-project/
chmod +x /path/to/your-project/scripts/*.sh
```

### Brownfield thủ công (chỉ packaging)

**Đừng** rsync full đè `CLAUDE.md` / `docs/` hiện có.

Khuyên:

```bash
./scripts/install-agent-team.sh /path/to/your-project --brownfield
```

Copy tay: chỉ `docs/agent-team/`, `docs/specs|plans|reviews/`, `AGENTS.md`, `GROK.md`, `scripts/*`; **merge** CLAUDE (hoặc sidecar `CLAUDE.agent-team.md`). `AGENTS.md` đã có → merge bảng role/SSOT tay (installer không đè).

---

## Vòng lặp hàng ngày (ngắn)

**0. Size** — nói `micro` / `small` / `full` (hoặc để Claude đề xuất). Ghi vào `STATE.size`.

| Size | Vòng |
|------|------|
| **micro** | HANDOFF mỏng → **Grok** (`invoke-grok`) → code review nhẹ (tuỳ). Claude **không** code. |
| **small** | Spec ⟲ sạch → **bạn OK** → Grok → code review → (bug → **bạn OK** → Grok fix). Plan tuỳ chọn. |
| **full** | Spec ⟲ → **bạn OK** → plan ⟲ → **bạn OK** → Grok → code review → (bug → **bạn OK** → Grok fix) |

**Mọi size:** Grok là coder; Claude chỉ spec/plan/review/orchestrate.  
**small/full:** Claude review-until-clean trước human; Grok fix cần `human_code_fix: approved`.

Chi tiết: [WORKFLOW.md](./WORKFLOW.md) · [USAGE.md](./USAGE.md).  
Mẫu file: [examples/demo-feature/](./examples/demo-feature/).  
Pack tuỳ chọn: [SUPERPOWERS-INTEGRATION.md](./SUPERPOWERS-INTEGRATION.md) · [ECC-INTEGRATION.md](./ECC-INTEGRATION.md).

---

## Adapter Grok CLI

```bash
# tên binary mặc định
export GROK_CMD="grok"

# lệnh nhiều từ (cố ý word-split):
# export GROK_CMD="grok --print"
# export GROK_CMD="grok -p"

# absolute path
# export GROK_CMD="/usr/local/bin/grok"

# CLI phức tạp: copy và sửa wrapper
# cp scripts/grok-wrapper.example.sh scripts/grok-wrapper.sh
# chmod +x scripts/grok-wrapper.sh
# # sửa REAL_GROK trong wrapper
# export GROK_CMD="$(pwd)/scripts/grok-wrapper.sh"

./scripts/invoke-grok.sh
./scripts/invoke-grok.sh "ghi chú thêm (tuỳ chọn)"
```

Xem comment trong [`scripts/grok-wrapper.example.sh`](../../scripts/grok-wrapper.example.sh).

### Preflight (`invoke-grok.sh` bắt buộc)

Từ chối launch nếu thiếu:

- `STATE.size` là `micro` \| `small` \| `full`
- HANDOFF + STATE đều phase `CODE`
- Feature slug khớp; iteration khớp; iteration ≥ 1
- **micro:** pre-code gates được `n/a`
- **small/full:** `human_spec` + `spec_review` approved; plan gates theo size
- Iter ≥ 2: `human_code_fix` approved
- `## Grok result` body chỉ `pending` (reject pass/fail)

Preflight fail → sửa HANDOFF/STATE / chờ human. Preflight ok mà CLI fail → sửa `GROK_CMD` / cài Grok.

---

## MCP (kiểu Context7)

Gộp entry `mcpServers` từ `.mcp.json.example` vào config MCP thật. Đừng rename-and-run nguyên file example. Index MCP = chỉ tra cứu; requirement chỉ trong spec + HANDOFF.

---

## Verify & test (sau cài)

```bash
./scripts/verify-skeleton.sh   # file bắt buộc + heading
./scripts/test-guards.sh       # unit test preflight invoke-grok
```
