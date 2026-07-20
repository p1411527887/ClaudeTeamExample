# Hướng dẫn Claude Code theo tinh thần Karpathy + Agent Team

Repo packaging này có **hai phần**:

1. **Hướng dẫn Karpathy** — `CLAUDE.md`, skill, ví dụ — giúp LLM code ít ẩu hơn.
2. **Template Agent-team** (`templates/agent-team/`, v1.3+) — Claude điều phối + chọn size micro/small/full + bạn duyệt + Grok code, SSOT trên disk.  
   Hướng dẫn chi tiết: [`templates/agent-team/docs/agent-team/USAGE.md`](./templates/agent-team/docs/agent-team/USAGE.md)  
   Cài: `./scripts/install-agent-team.sh`

Tài liệu repo này dùng **tiếng Việt**.

---

Một file `CLAUDE.md` để cải thiện hành vi Claude Code, dựa trên [quan sát của Andrej Karpathy](https://x.com/karpathy/status/2015883857489522876) về các lỗi LLM hay mắc khi code.

## Vấn đề

Từ bài của Andrej (tóm tắt):

- Model hay **đoán mò** rồi làm tiếp, không hỏi, không nêu tradeoff, không phản biện khi cần.
- Hay **làm phức tạp** code/API, abstraction dư, hàng trăm dòng trong khi vài chục là đủ.
- Đôi khi **sửa/xóa** comment hoặc code không liên quan.

## Giải pháp — bốn nguyên tắc

| Nguyên tắc | Xử lý |
|------------|--------|
| **Think Before Coding** | Giả định sai, che giấu bối rối, thiếu tradeoff |
| **Simplicity First** | Over-engineer, abstraction phình |
| **Surgical Changes** | Sửa lung tung ngoài phạm vi |
| **Goal-Driven Execution** | Mục tiêu có verify, test-first |

### 1. Think Before Coding

**Đừng đoán. Đừng giấu bối rối. Nêu tradeoff.**

- Nêu giả định rõ; không chắc thì hỏi
- Nhiều cách hiểu → trình bày, đừng chọn thầm
- Có cách đơn giản hơn → nói ra
- Bối rối → dừng, nêu chỗ chưa rõ, hỏi

### 2. Simplicity First

**Code tối thiểu đủ việc. Không suy đoán thừa.**

- Không feature ngoài yêu cầu
- Không abstraction chỉ dùng một lần
- Không “config linh hoạt” khi chưa ai hỏi
- Không try/catch cho case không thể xảy ra
- 200 dòng mà 50 đủ → viết lại

**Thử:** Senior có bảo “phức tạp quá” không? Có → đơn giản hóa.

### 3. Surgical Changes

**Chỉ đụng phần cần. Chỉ dọn rác do mình tạo.**

Khi sửa code có sẵn:

- Đừng “cải thiện” code/comment/format bên cạnh
- Đừng refactor thứ đang chạy ổn
- Bám style hiện có
- Dead code không liên quan → nhắc, **đừng** xóa bừa

Rác do thay đổi của bạn tạo ra → xóa import/hàm không dùng. Dead code cũ → chỉ xóa khi được yêu cầu.

**Thử:** Mọi dòng diff phải truy về đúng yêu cầu.

### 4. Goal-Driven Execution

**Định nghĩa tiêu chí thành công. Lặp đến khi verify được.**

| Thay vì… | Thành… |
|----------|--------|
| “Thêm validation” | “Viết test input invalid rồi làm pass” |
| “Sửa bug” | “Viết test tái hiện rồi làm pass” |
| “Refactor X” | “Test pass trước và sau” |

Multi-step:

```text
1. [Bước] → verify: [kiểm tra]
2. [Bước] → verify: [kiểm tra]
```

Tiêu chí mạnh → LLM tự loop. Tiêu chí yếu (“cho chạy được”) → phải hỏi liên tục.

## Cài hướng dẫn Karpathy

**Cách A: Plugin Claude Code**

```text
/plugin marketplace add forrestchang/andrej-karpathy-skills
/plugin install andrej-karpathy-skills@karpathy-skills
```

**Cách B: File `CLAUDE.md` theo project**

```bash
# Project mới
curl -o CLAUDE.md https://raw.githubusercontent.com/forrestchang/andrej-karpathy-skills/main/CLAUDE.md

# Project có sẵn (nối thêm)
echo "" >> CLAUDE.md
curl https://raw.githubusercontent.com/forrestchang/andrej-karpathy-skills/main/CLAUDE.md >> CLAUDE.md
```

## Dùng với VS Code / editor khác

- **Claude Code / agent trong VS Code:** dùng root [`CLAUDE.md`](CLAUDE.md) (và skill nếu plugin hỗ trợ).
- **Project app dùng Agent-team:** cài template rồi đọc [`USAGE.md`](./templates/agent-team/docs/agent-team/USAGE.md).

## Làm sao biết đang “đúng hướng”

- Diff gọn, ít sửa ngoài phạm vi
- Ít phải viết lại vì over-engineer
- Hỏi làm rõ **trước** khi code ẩu
- PR sạch, không refactor “tiện tay”

## Ghi chú tradeoff

Hướng dẫn thiên về **cẩn thận hơn tốc độ**. Task trivial (typo, một dòng rõ) → dùng phán đoán, không cần full nghi thức.

## Template Agent Team (Claude + Grok)

Skeleton multi-agent: Claude điều phối, Grok code qua CLI, SSOT trên disk + HANDOFF + sizing:

| Tài liệu | Mô tả |
|----------|--------|
| [`templates/agent-team/`](./templates/agent-team/) | Skeleton |
| [`USAGE.md`](./templates/agent-team/docs/agent-team/USAGE.md) | **Hướng dẫn xài chi tiết (tiếng Việt)** |
| [`docs/agent-team/README.md`](./templates/agent-team/docs/agent-team/README.md) | Cài greenfield/brownfield |
| Superpowers / ECC | Tuỳ chọn — xem file trong template |
| Design / plan | `docs/superpowers/` |

**`CLAUDE.md` hai vai trò**

| Vị trí | Ý nghĩa |
|--------|---------|
| Root [`CLAUDE.md`](./CLAUDE.md) | Karpathy cho *repo packaging này* |
| [`templates/agent-team/CLAUDE.md`](./templates/agent-team/CLAUDE.md) | Contract **orchestrator** sau khi cài vào app |

### Cài template vào project app — hiểu đúng trước khi gõ lệnh

Có **hai chỗ khác nhau**. Install **không** tự bay sang app: bạn phải trỏ path.

| | **Repo packaging** (repo này, ví dụ `ClaudeTeamExample`) | **Project app** (app bạn code, ví dụ `my-shop`) |
|--|----------------------------------------------------------|--------------------------------------------------|
| Vai trò | Chứa **khuôn** `templates/agent-team/` + script cài | Nơi **thật sự** làm feature |
| Bạn làm gì | Chạy **1 lệnh install**, trỏ path sang app | Vào app → verify → dùng Claude / Grok |

```text
[ClaudeTeamExample]  ./scripts/install-agent-team.sh  →  [my-shop]
                              (copy khuôn)
[my-shop]  verify-skeleton + test-guards
[my-shop]  Claude + (khi CODE) invoke-grok
```

**Không** cần mỗi ngày quay lại packaging. Packaging chỉ lúc:

- **Cài lần đầu** vào app, hoặc  
- **Nâng cấp** template (`install --brownfield` lại)

#### Ví dụ cụ thể

Giả sử:

- Packaging: `~/Documents/ClaudeTeamExample`
- App: `~/Documents/my-shop`

**Bước 1 — đứng ở repo packaging, chạy install**

```bash
cd ~/Documents/ClaudeTeamExample

# App đã có code / git → brownfield (an toàn hơn, khuyên dùng)
./scripts/install-agent-team.sh ~/Documents/my-shop --brownfield

# App trống hoàn toàn
# ./scripts/install-agent-team.sh ~/Documents/my-shop --greenfield
```

Lệnh này **copy** skeleton (`CLAUDE`/`AGENTS`/`GROK`, `docs/agent-team/`, scripts…) **vào** `my-shop`.

**Bước 2 — đứng ở project app, kiểm tra**

```bash
cd ~/Documents/my-shop
./scripts/verify-skeleton.sh && ./scripts/test-guards.sh
```

Hai script này **đã nằm trong app** sau bước 1 (không chạy trong packaging nữa, trừ khi bạn test template).

**Bước 3 — làm việc trong app**

- Mở **`my-shop`** bằng VS Code + Claude  
- Đọc `docs/agent-team/USAGE.md`  
- Nói: `size: small — …`  
- Khi đến CODE: trong **my-shop** chạy `./scripts/invoke-grok.sh`

#### Các flag install

| Lệnh / flag | Ý nghĩa |
|-------------|---------|
| `./scripts/install-agent-team.sh /path/to/app` | Auto: folder **trống** → greenfield; **đã có file** → brownfield |
| `--greenfield` | Copy full template; **từ chối** nếu folder đã có đồ (trừ `--force`) |
| `--greenfield --force` | Greenfield dù folder không trống (có thể đè file trùng tên) |
| `--brownfield` | Cài vào project cũ; **không đè** `CLAUDE.md`; **giữ** `STATE.md` / `HANDOFF.md` |
| `--dry-run` | Chỉ in ra sẽ làm gì, **chưa** copy |

```bash
# Từ root repo packaging (ClaudeTeamExample)
./scripts/install-agent-team.sh /path/to/your-project
./scripts/install-agent-team.sh /path/to/your-project --greenfield
./scripts/install-agent-team.sh /path/to/your-project --greenfield --force
./scripts/install-agent-team.sh /path/to/your-project --brownfield
./scripts/install-agent-team.sh /path/to/your-project --dry-run
```

#### Tóm một câu

**Chạy bash ở repo packaging (install, trỏ path app) → sang app chạy bash verify → sau đó chỉ làm việc trong app.**  
Script làm giúp phần copy; không phải copy tay từng file.

CI template: [`.github/workflows/agent-team-ci.yml`](./.github/workflows/agent-team-ci.yml).

## Giấy phép

MIT — xem [`LICENSE`](./LICENSE).
