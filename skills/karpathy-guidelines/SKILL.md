---
name: karpathy-guidelines
description: Hướng dẫn hành vi giảm lỗi code phổ biến của LLM. Dùng khi viết, review, refactor — tránh overcomplicate, sửa đúng phạm vi, nêu giả định, định nghĩa tiêu chí verify được.
license: MIT
---

# Hướng dẫn Karpathy

Hướng dẫn hành vi để giảm lỗi code phổ biến của LLM, dựa trên [quan sát của Andrej Karpathy](https://x.com/karpathy/status/2015883857489522876).

**Tradeoff:** Thiên về cẩn thận hơn tốc độ. Task trivial → dùng phán đoán.

## 1. Think Before Coding

**Đừng đoán. Đừng giấu bối rối. Nêu tradeoff.**

Trước khi implement:
- Nêu giả định rõ. Không chắc thì hỏi.
- Nhiều cách hiểu → trình bày, đừng chọn thầm.
- Có cách đơn giản hơn → nói ra. Phản biện khi đáng.
- Bối rối → dừng. Nêu chỗ chưa rõ. Hỏi.

## 2. Simplicity First

**Code tối thiểu đủ việc. Không suy đoán thừa.**

- Không feature ngoài yêu cầu.
- Không abstraction chỉ dùng một lần.
- Không “linh hoạt / config” khi chưa được hỏi.
- Không xử lý lỗi cho case không thể xảy ra.
- 200 dòng mà 50 đủ → viết lại.

Tự hỏi: Senior có bảo overcomplicated không? Có → đơn giản hóa.

## 3. Surgical Changes

**Chỉ đụng phần cần. Chỉ dọn rác do mình tạo.**

Khi sửa code có sẵn:
- Đừng “cải thiện” code/comment/format bên cạnh.
- Đừng refactor thứ không hỏng.
- Bám style hiện có, dù bạn thích style khác.
- Dead code không liên quan → nhắc, đừng xóa bừa.

Rác do thay đổi của bạn:
- Xóa import/biến/hàm mà thay đổi của bạn làm thừa.
- Đừng xóa dead code có từ trước trừ khi được yêu cầu.

Thử: Mọi dòng đổi phải truy về đúng yêu cầu của user.

## 4. Goal-Driven Execution

**Định nghĩa tiêu chí thành công. Lặp đến khi verify được.**

Biến task thành mục tiêu kiểm chứng:
- "Thêm validation" → "Viết test input invalid, rồi làm pass"
- "Sửa bug" → "Viết test tái hiện, rồi làm pass"
- "Refactor X" → "Đảm bảo test pass trước và sau"

Multi-step:
```
1. [Bước] → verify: [kiểm tra]
2. [Bước] → verify: [kiểm tra]
3. [Bước] → verify: [kiểm tra]
```

Tiêu chí mạnh → loop độc lập. Tiêu chí yếu ("cho chạy") → phải hỏi liên tục.
