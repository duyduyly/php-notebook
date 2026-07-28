# AcyMailing 10.11.1 Installation and Test Guide for Joomla 6

Hướng dẫn này mô tả cách:

- Cài đặt AcyMailing 10.11.1 trên Joomla 6.
- Deploy source sang môi trường khác bằng Git và Joomla Discover.
- Kiểm tra extension đã cài đặt và hoạt động đúng.
- Tạo, đổi hoặc thay thế subscriber test trong Joomla backend.

> **Lưu ý:** Trong AcyMailing, tài khoản nhận email được gọi là **subscriber/user**. Nó không nhất thiết là tài khoản đăng nhập Joomla.

## Table of Contents

- [1. Prerequisites](#1-prerequisites)
- [2. Install AcyMailing on Local](#2-install-acymailing-on-local)
- [3. Push Source to Git](#3-push-source-to-git)
- [4. Install on Development](#4-install-on-development)
- [5. Test the Installation](#5-test-the-installation)
- [6. Create a Test Subscriber](#6-create-a-test-subscriber)
- [7. Change or Replace a Subscriber](#7-change-or-replace-a-subscriber)
- [8. Final Checklist](#8-final-checklist)
- [9. Troubleshooting](#9-troubleshooting)

---

## 1. Prerequisites

Kiểm tra trước khi cài đặt:

```text
[ ] Joomla 6 đã chạy bình thường
[ ] Database đã kết nối
[ ] PHP version tương thích với Joomla 6
[ ] Có file cài đặt AcyMailing 10.11.1 chính thức
[ ] Đã backup database
[ ] Git working tree sạch
```

Kiểm tra Git:

```bash
git status
```

Tạo branch riêng:

```bash
git checkout -b feature/install-acymailing-10.11.1
```

Không commit các file chứa thông tin nhạy cảm:

```text
configuration.php
.env
SMTP password
API key
License key
Database backup
Subscriber production data
```

---

## 2. Install AcyMailing on Local

### Step 1: Mở Extension Installer

Trong Joomla Administrator:

```text
System
→ Install
→ Extensions
```

### Step 2: Upload package

Chọn:

```text
Upload Package File
```

Upload file chính thức, ví dụ:

```text
acymailing_10.11.1.zip
```

Không giải nén ZIP rồi copy thủ công vào source Joomla.

### Step 3: Kiểm tra kết quả

Đi đến:

```text
System
→ Manage
→ Extensions
```

Tìm:

```text
AcyMailing
```

Sau đó mở:

```text
Components
→ AcyMailing
```

Kết quả mong đợi:

```text
[ ] Component AcyMailing tồn tại
[ ] Plugin và module liên quan đã được cài đặt
[ ] Extension cần thiết đang Enabled
[ ] Version hiển thị là 10.11.1
[ ] Dashboard mở không có lỗi HTTP 500
```

---

## 3. Push Source to Git

Kiểm tra các file được tạo sau khi cài đặt:

```bash
git status --short
git diff --stat
```

AcyMailing có thể tạo file trong các thư mục:

```text
administrator/components/
components/
media/
modules/
plugins/
language/
administrator/language/
libraries/
```

Tìm file liên quan:

```bash
find administrator components media modules plugins libraries \
  -iname '*acym*' 2>/dev/null
```

Commit và push:

```bash
git add administrator components media modules plugins language libraries

git commit -m "feat: install AcyMailing 10.11.1 for Joomla 6"

git push origin feature/install-acymailing-10.11.1
```

Điều chỉnh danh sách `git add` theo kết quả thực tế của `git status`.

> Không commit file ZIP của bản trả phí vào public repository.

---

## 4. Install on Development

### Recommended method: Install the official ZIP

Phương án an toàn nhất trên development:

```text
Joomla Administrator
→ System
→ Install
→ Extensions
→ Upload AcyMailing ZIP
```

AcyMailing là package gồm nhiều extension, vì vậy cài lại ZIP chính thức an toàn hơn chỉ dùng Discover.

### Alternative method: Git source + Discover

Chỉ dùng khi team đã kiểm chứng trên database Joomla 6 sạch.

Sau khi pull source:

```text
System
→ Install
→ Discover
→ Discover
```

Tìm:

```text
AcyMailing
acym
```

Nếu Joomla phát hiện nhiều extension, cài tất cả extension liên quan.

Thứ tự ưu tiên khi không có package entry:

```text
Library
→ Component
→ Plugin
→ Module
```

Sau đó:

```text
System
→ Maintenance
→ Clear Cache
```

> Nếu component tồn tại nhưng thiếu database table hoặc dependency, hãy restore database và cài lại ZIP chính thức.

---

## 5. Test the Installation

### 5.1 Test extension registration

Đi đến:

```text
System
→ Manage
→ Extensions
```

Tìm `AcyMailing` và xác nhận:

```text
[ ] Main component tồn tại
[ ] Plugin liên quan tồn tại
[ ] Module liên quan tồn tại nếu package có cung cấp
[ ] Extension cần thiết đang Enabled
[ ] Version là 10.11.1
```

### 5.2 Test dashboard

Mở:

```text
Components
→ AcyMailing
```

Các trang sau phải mở được:

```text
Dashboard
Users
Lists
Campaigns
Templates
Configuration
Queue
```

Không được có các lỗi:

```text
HTTP 500
Table not found
Class not found
Plugin not found
Missing dependency
```

### 5.3 Test database

Thay `yourprefix_` bằng database prefix thực tế.

```sql
SHOW TABLES LIKE 'yourprefix_acym_%';
```

Phải có các bảng AcyMailing.

Kiểm tra extension record:

```sql
SELECT
    extension_id,
    name,
    type,
    element,
    folder,
    enabled
FROM yourprefix_extensions
WHERE name LIKE '%AcyMailing%'
   OR element LIKE '%acym%'
   OR folder LIKE '%acym%'
ORDER BY type, name;
```

### 5.4 Test Joomla mail configuration

Đi đến:

```text
System
→ Global Configuration
→ Server
→ Mail
```

Nhấn:

```text
Send Test Mail
```

Nếu Joomla không gửi được test mail, hãy sửa SMTP trước khi test campaign của AcyMailing.

### 5.5 Test AcyMailing email

Đi đến:

```text
Components
→ AcyMailing
→ Configuration
→ Mail settings
```

Gửi một test email đến địa chỉ của bạn.

Kiểm tra:

```text
[ ] AcyMailing báo gửi thành công
[ ] Email xuất hiện trong Inbox hoặc Spam
[ ] From Name và From Email đúng
[ ] Nội dung HTML hiển thị đúng
[ ] Link trong email dùng đúng domain
```

### 5.6 Test campaign flow

Thực hiện lần lượt:

1. Tạo test list.
2. Tạo test subscriber.
3. Thêm subscriber vào test list.
4. Tạo một campaign đơn giản.
5. Gửi campaign đến test list.
6. Kiểm tra email đã nhận.
7. Kiểm tra Queue không bị lỗi.
8. Kiểm tra link unsubscribe hoạt động.

Kết quả đạt yêu cầu:

```text
[ ] Campaign gửi thành công
[ ] Subscriber nhận được email
[ ] Queue chuyển từ Pending sang Sent
[ ] Unsubscribe link mở đúng
[ ] Subscriber được unsubscribe khỏi đúng list
```

### 5.7 Test frontend subscription form

Nếu website có form đăng ký newsletter:

1. Publish AcyMailing subscription module.
2. Mở frontend.
3. Đăng ký bằng email test mới.
4. Kiểm tra user xuất hiện trong AcyMailing Users.
5. Kiểm tra user thuộc đúng list.
6. Kiểm tra confirmation email nếu bật double opt-in.

---

## 6. Create a Test Subscriber

Trong Joomla Administrator:

```text
Components
→ AcyMailing
→ Users
→ New
```

Nhập:

```text
Name: Test User
Email: your-email@example.com
Active: Yes
Confirmed: Yes
```

Sau đó thêm user vào test list trong phần subscription/list assignment.

Có thể dùng Gmail plus addressing để tạo nhiều subscriber test nhưng vẫn nhận email trong cùng một inbox:

```text
yourname+acym-active@gmail.com
yourname+acym-confirm@gmail.com
yourname+acym-unsubscribe@gmail.com
```

---

## 7. Change or Replace a Subscriber

### Case 1: Đổi email của subscriber hiện tại

Dùng khi muốn giữ nguyên subscription và chỉ đổi địa chỉ email.

```text
Components
→ AcyMailing
→ Users
→ mở subscriber
→ đổi Email
→ Save & Close
```

Sau khi lưu, kiểm tra:

```text
[ ] Email mới đã được cập nhật
[ ] Subscriber vẫn thuộc đúng list
[ ] Active = Yes
[ ] Confirmed = Yes nếu cần
[ ] Campaign gửi đến email mới
```

### Case 2: Giữ user cũ và tạo subscriber test mới

Dùng khi muốn giữ lịch sử test cũ.

```text
Components
→ AcyMailing
→ Users
→ New
```

Tạo subscriber mới và thêm vào test list.

Đây là phương án được đề xuất cho môi trường test vì có thể kiểm tra nhiều trạng thái khác nhau.

### Case 3: Không muốn email cũ tiếp tục nhận mail

Không cần xóa user. Chỉ cần unsubscribe khỏi list:

```text
Components
→ AcyMailing
→ Users
→ mở subscriber
→ Subscription
→ Unsubscribe khỏi test list
→ Save
```

Phân biệt các thao tác:

| Action | Result |
|---|---|
| Change email | Giữ subscriber hiện tại và chuyển sang email mới |
| Unsubscribe | User vẫn tồn tại nhưng không nhận email từ list đó |
| Delete | Xóa subscriber khỏi AcyMailing |

### Case 4: Subscriber liên kết với Joomla user account

Nếu subscriber có `CMS user ID` hoặc liên kết với tài khoản Joomla, nên đổi email trong Joomla trước:

```text
Users
→ Manage
→ mở Joomla user
→ đổi Email
→ Save & Close
```

Sau đó kiểm tra lại:

```text
Components
→ AcyMailing
→ Users
```

Không nên chỉ đổi email trong AcyMailing nếu hệ thống đang đồng bộ user từ Joomla, vì lần đồng bộ tiếp theo có thể ghi đè dữ liệu.

---

## 8. Final Checklist

AcyMailing được xem là cài đặt thành công khi:

```text
[ ] AcyMailing xuất hiện trong Joomla Extensions
[ ] Dashboard mở không lỗi
[ ] Version hiển thị là 10.11.1
[ ] Database tables đã được tạo
[ ] Joomla gửi được test mail
[ ] AcyMailing gửi được test email
[ ] Tạo được list và subscriber
[ ] Gửi được campaign
[ ] Queue xử lý thành công
[ ] Frontend subscription form hoạt động nếu được sử dụng
[ ] Unsubscribe hoạt động
[ ] Có thể đổi hoặc thay thế subscriber từ backend
[ ] Joomla logs không có lỗi nghiêm trọng
```

### Smoke test nhanh sau mỗi lần deploy

```text
1. Mở Components → AcyMailing.
2. Gửi một test email.
3. Kiểm tra test subscriber và test list.
4. Gửi một campaign nhỏ.
5. Kiểm tra email, Queue và unsubscribe.
```

---

## 9. Troubleshooting

### Dashboard báo HTTP 500

Kiểm tra Joomla log và Docker log:

```bash
docker compose logs --tail=200 joomla
```

Tìm các lỗi:

```text
Missing class
Missing file
Missing database table
PHP compatibility error
```

### Component tồn tại nhưng thiếu database table

Khuyến nghị:

1. Restore database backup nếu trạng thái không nhất quán.
2. Cài lại AcyMailing bằng ZIP chính thức.
3. Kiểm tra lại `#__extensions` và `#__acym_*`.

Không tự chèn record vào `#__extensions` hoặc tự tạo bảng AcyMailing như phương án deploy thông thường.

### Discover không tìm thấy AcyMailing

Kiểm tra:

```text
[ ] Source đã được pull đầy đủ
[ ] Manifest XML tồn tại
[ ] File nằm đúng Joomla extension directories
[ ] Web server có quyền đọc file
[ ] Extension chưa tồn tại trong #__extensions
```

Tìm manifest:

```bash
find administrator components modules plugins libraries \
  -type f -name '*.xml' \
  | grep -i acym
```

### Joomla gửi mail được nhưng AcyMailing không gửi được

Kiểm tra:

```text
AcyMailing Configuration
SMTP settings
From Email
Reply-to Email
Queue
Cron/Scheduled Task
Spam folder
Mail provider logs
```
