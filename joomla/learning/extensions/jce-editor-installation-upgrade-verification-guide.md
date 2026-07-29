# JCE Editor — Installation, Core-to-Pro Upgrade and Verification Guide

## 1. Thông tin cài đặt

| Field               | Value                                          |
| ------------------- | ---------------------------------------------- |
| Extension           | JCE – Joomla Content Editor                    |
| Vendor              | Widget Factory Limited                         |
| Extension family    | Component, editor plugin và supporting plugins |
| Core edition        | Free                                           |
| Pro edition         | Paid subscription                              |
| Recommended version | `2.9.99.9` hoặc mới hơn                        |
| Joomla support      | Joomla 3.9+, Joomla 4, Joomla 5 và Joomla 6    |
| Recommended method  | Upload Package File                            |

Trang tải JCE Core chính thức xác nhận bản `2.9.99.9` là package dành cho Joomla 3.9+, 4, 5 và 6.

---

# 2. Link tải chính thức

## 2.1 JCE Core — bản miễn phí

Trang tải Core:

```text
https://www.joomlacontenteditor.net/downloads/editor/core
```

Trang tải mới nhất:

```text
https://www.joomlacontenteditor.net/downloads/editor/core/latest
```

JCE Core có thể tải mà không cần JCE Pro subscription.

## 2.2 JCE Pro — bản trả phí

Trang sản phẩm:

```text
https://www.joomlacontenteditor.net/products/jce-pro
```

Trang đăng ký subscription:

```text
https://www.joomlacontenteditor.net/component/subscriptions/purchase
```

Trang tải JCE Pro mới nhất:

```text
https://www.joomlacontenteditor.net/downloads/editor/pro/latest
```

Bạn phải:

1. Tạo tài khoản JCE.
2. Mua JCE Pro subscription.
3. Đăng nhập tài khoản.
4. Tải package JCE Pro.

JCE Pro subscription cung cấp quyền tải bản Pro và cập nhật qua Joomla Updater trong thời gian subscription còn hiệu lực. Khi subscription hết hạn, quyền tải và cập nhật Pro cũng hết.

## 2.3 Tài liệu cài đặt chính thức

```text
https://www.joomlacontenteditor.net/support/installation/editor
```

Vendor hướng dẫn tải package, mở `System → Install → Extensions`, chọn `Upload Package File` và upload ZIP.

---

# 3. Chuẩn bị trước khi cài đặt

Trước khi cài JCE:

* Backup database.
* Backup source code.
* Xác nhận Joomla 6 hoạt động ổn định.
* Xác nhận tài khoản đang dùng có quyền Super User.
* Xác nhận thư mục `tmp` và `logs` writable.
* Xác nhận PHP extension ZIP được bật.
* Gỡ hoặc xử lý các installation package JCE bị lỗi trước đó.
* Kiểm tra website có JCE cũ hay không.
* Nếu website từng dùng JCE `2.9.99.4` trở xuống, thực hiện security review trước khi migration.

Không nên uninstall JCE hiện tại trước khi update cùng edition, vì uninstall có thể làm mất cấu hình hoặc profile không cần thiết.

---

# 4. Cài đặt JCE Core bằng Joomla Install

## Step 1: Tải package Core

Mở:

```text
https://www.joomlacontenteditor.net/downloads/editor/core/latest
```

Tải Joomla installation package dạng ZIP.

Không giải nén ZIP.

Ví dụ tên file:

```text
com_jce_29999.zip
```

Tên file thực tế có thể khác tùy release.

## Step 2: Đăng nhập Joomla Administrator

Mở:

```text
https://your-domain.example/administrator
```

Đăng nhập bằng Super User.

## Step 3: Mở Extension Installer

Đi đến:

```text
System
→ Install
→ Extensions
```

Chọn tab:

```text
Upload Package File
```

## Step 4: Upload package

1. Chọn **Browse for file**.
2. Chọn file ZIP JCE Core.
3. Chờ Joomla upload và chạy installer.
4. Không đóng browser trong lúc cài đặt.

Joomla hỗ trợ cài extension bằng Upload Package File, Install from Folder, Install from URL hoặc Install from Web.

## Step 5: Xác nhận kết quả

Kết quả mong đợi:

```text
Installation of the package was successful.
```

JCE có thể cài nhiều extension con như:

* JCE component.
* Editor plugin.
* Extension plugin.
* Media-related plugins.
* Finder hoặc link-related plugins.
* Installer/update-related entries.

## Step 6: Kiểm tra extension đã đăng ký

Đi đến:

```text
System
→ Manage
→ Extensions
```

Tìm:

```text
JCE
```

Hoặc tìm các element liên quan:

```text
com_jce
plg_editors_jce
```

Kiểm tra:

* Component JCE có tồn tại.
* Editor plugin JCE được enabled.
* Không có duplicate package.
* Version đúng với package vừa cài.

## Step 7: Mở JCE Control Panel

Đi đến:

```text
Components
→ JCE Editor
```

Xác nhận Control Panel mở được mà không có PHP hoặc JavaScript error.

## Step 8: Đặt JCE làm editor mặc định

Đi đến:

```text
System
→ Global Configuration
→ Site
```

Tìm:

```text
Default Editor
```

Chọn:

```text
Editor - JCE
```

Nhấn:

```text
Save & Close
```

## Step 9: Kiểm tra user-specific editor

Joomla cho phép từng user chọn editor riêng.

Đi đến:

```text
Users
→ Manage
→ Chọn user
→ Basic Settings
```

Kiểm tra:

```text
Editor: Use Default
```

Hoặc chọn trực tiếp:

```text
Editor - JCE
```

Nếu user đã đặt TinyMCE riêng, Global Configuration sẽ không tự ghi đè lựa chọn này.

---

# 5. Cài đặt JCE bằng Discover

## 5.1 Khi nào sử dụng Discover?

Chỉ dùng Discover khi:

* Joomla Upload Package File không hoạt động.
* Package quá lớn so với PHP upload limit.
* Source được deploy qua Git, Docker hoặc CI/CD.
* File đã được chép trực tiếp vào Joomla filesystem.
* Hosting không cho upload ZIP qua backend.

Discover **không tự upload hoặc giải nén package**. Nó chỉ tìm manifest của extension đã tồn tại trong filesystem.

## 5.2 Cảnh báo đối với JCE

JCE không phải một plugin đơn lẻ. Nó là package gồm nhiều thành phần và có installation script.

Do đó:

> Không nên chỉ chép `administrator/components/com_jce` rồi chạy Discover.

Cách này có thể thiếu:

* Editor plugin.
* Supporting plugins.
* Media assets.
* Language files.
* Database installation.
* Update-site records.
* Installer script actions.

Phương pháp Discover cho JCE chỉ phù hợp khi bạn hiểu đầy đủ cấu trúc package.

## Step 1: Tải đúng installation package

Tải JCE Core hoặc JCE Pro từ nguồn chính thức.

Không sử dụng:

```text
GitHub Source code.zip
```

nếu đó không phải Joomla installation package do vendor build.

## Step 2: Giải nén package ở máy local

Ví dụ:

```bash
mkdir -p /tmp/jce-package
unzip com_jce_package.zip -d /tmp/jce-package
```

Kiểm tra package manifest:

```bash
find /tmp/jce-package -maxdepth 3 -type f -name "*.xml"
```

Tìm manifest package, thường có dạng:

```text
pkg_jce.xml
```

hoặc manifest tương ứng với release.

## Step 3: Kiểm tra package manifest

Mở XML và xem các package con:

```bash
grep -RInE \
"<extension|<file|type=\"package\"|type=\"component\"|type=\"plugin\"" \
/tmp/jce-package
```

Không đoán đường dẫn chỉ từ tên extension. Manifest cho biết package chứa component và plugin nào.

## Step 4: Chép từng extension vào đúng vị trí

Các vị trí Joomla có thể bao gồm:

```text
administrator/components/com_jce/
components/com_jce/
plugins/editors/jce/
plugins/extension/
plugins/system/
plugins/content/
media/com_jce/
administrator/language/
language/
```

Đường dẫn thực tế phải dựa trên package manifest.

Không copy toàn bộ package vào:

```text
administrator/components/com_jce/
```

vì package root không phải component root.

## Step 5: Đặt quyền file

Ví dụ trong Linux/Docker:

```bash
chown -R www-data:www-data \
  administrator/components/com_jce \
  components/com_jce \
  plugins/editors/jce \
  media/com_jce

find administrator/components/com_jce \
  components/com_jce \
  plugins/editors/jce \
  media/com_jce \
  -type d -exec chmod 755 {} \;

find administrator/components/com_jce \
  components/com_jce \
  plugins/editors/jce \
  media/com_jce \
  -type f -exec chmod 644 {} \;
```

Điều chỉnh danh sách thư mục theo package thực tế.

## Step 6: Chạy Joomla Discover

Đi đến:

```text
System
→ Install
→ Discover
```

Nhấn:

```text
Discover
```

Joomla có thể phát hiện nhiều record JCE riêng biệt:

* Component.
* Editor plugin.
* Extension plugins.
* Supporting plugins.

## Step 7: Cài các extension đã discover

1. Chọn các record thuộc JCE.
2. Cài component trước nếu cần.
3. Cài editor plugin.
4. Cài supporting plugins.
5. Kiểm tra installation messages.

## Step 8: Kiểm tra thiếu thành phần

Đi đến:

```text
System
→ Manage
→ Extensions
```

Tìm `JCE`.

So sánh danh sách với một môi trường đã cài bằng ZIP thành công.

## Step 9: Kiểm tra database

Đi đến:

```text
System
→ Maintenance
→ Database
```

Nếu Joomla báo schema issue:

1. Chọn extension liên quan.
2. Nhấn **Update Structure** hoặc **Fix** nếu giao diện cung cấp.
3. Không tự chạy SQL không rõ nguồn gốc trên production.

## Khuyến nghị cuối cùng về Discover

Nếu Discover chỉ nhận một phần của JCE hoặc JCE Control Panel không hoạt động:

1. Xóa các file copy thủ công khỏi staging.
2. Khôi phục backup nếu cần.
3. Dùng lại official ZIP với Upload Package File hoặc Install from Folder.

---

# 6. Cài đặt bằng Install from Folder

Đây thường là phương án tốt hơn Discover khi package lớn.

## Step 1: Upload và giải nén package vào thư mục tạm

Ví dụ:

```bash
mkdir -p /var/www/html/tmp/jce-install
unzip com_jce_package.zip -d /var/www/html/tmp/jce-install
chown -R www-data:www-data /var/www/html/tmp/jce-install
```

## Step 2: Mở Joomla installer

Đi đến:

```text
System
→ Install
→ Extensions
→ Install from Folder
```

## Step 3: Nhập đường dẫn

Ví dụ:

```text
/var/www/html/tmp/jce-install
```

## Step 4: Chọn Install

Joomla sẽ chạy package installer và installation script đầy đủ.

Phương án này tốt hơn Discover vì Joomla vẫn xử lý package như một installation package hoàn chỉnh.

---

# 7. Upgrade JCE Core lên JCE Pro

## Kết luận quan trọng

Bạn **không thể chỉ nhập Subscription Key để biến Core thành Pro**.

Subscription Key chỉ cho phép Joomla xác thực quyền tải và cập nhật các package Pro. Bạn vẫn phải tải và cài **JCE Pro package**. Vendor xác nhận nhập key không “activate” Core thành Pro.

## Step 1: Backup

Backup:

* Database.
* Joomla source.
* JCE Editor Profiles.
* JCE configuration.
* Custom plugin settings.
* Template editor CSS.

## Step 2: Mua subscription

Mở:

```text
https://www.joomlacontenteditor.net/products/jce-pro
```

Chọn subscription phù hợp và hoàn tất thanh toán.

## Step 3: Lấy Subscription Key

Đăng nhập tài khoản JCE.

Mở khu vực subscription/account và lấy:

```text
Subscription Key
```

Key được dùng bởi JCE Updater và Joomla Update Manager để cấp quyền tải update Pro.

Không public key trong:

* GitHub repository.
* Public documentation.
* Screenshot.
* Support ticket công khai.
* `.env.example`.

## Step 4: Tải JCE Pro package

Sau khi đăng nhập, mở:

```text
https://www.joomlacontenteditor.net/downloads/editor/pro/latest
```

Tải package Pro mới nhất.

## Step 5: Không uninstall JCE Core

Đối với Core → Pro:

> Cài JCE Pro trực tiếp lên JCE Core bằng Joomla Extension Installer.

Không uninstall Core trước, trừ khi vendor support yêu cầu cho một lỗi cụ thể.

JCE support xác nhận Core không thể tự update thành Pro qua Joomla Updater khi hai edition có cùng version; phải tải và cài package Pro trực tiếp.

## Step 6: Cài JCE Pro package

Đi đến:

```text
System
→ Install
→ Extensions
→ Upload Package File
```

Upload JCE Pro ZIP.

Kết quả mong đợi:

```text
Installation of the package was successful.
```

Existing Editor Profiles thường được giữ lại.

## Step 7: Nhập Subscription Key

Có thể nhập key trong JCE configuration, tùy giao diện phiên bản:

```text
Components
→ JCE Editor
→ Control Panel
→ Options
```

Tìm phần:

```text
Updates
Subscription Key
Download Key
```

Dán key và lưu.

Một số Joomla version cũng quản lý key qua:

```text
System
→ Update
→ Update Sites
```

Tìm update site của JCE Pro và nhập Download Key nếu field được cung cấp.

## Step 8: Rebuild Update Sites nếu cần

Nếu Joomla vẫn hiển thị update Core hoặc không nhận đúng Pro:

```text
System
→ Update
→ Update Sites
```

Nhấn:

```text
Rebuild
```

Vendor hướng dẫn rebuild update sites khi dữ liệu Core/Pro cũ gây xung đột update.

## Step 9: Kiểm tra edition

Đi đến:

```text
Components
→ JCE Editor
→ Control Panel
```

Xác nhận edition hiển thị là:

```text
JCE Pro
```

## Step 10: Thêm các nút Pro vào toolbar

Sau khi Core → Pro, các nút Pro có thể chưa tự xuất hiện vì JCE giữ nguyên Editor Profile hiện tại.

Đi đến:

```text
Components
→ JCE Editor
→ Editor Profiles
```

Mở:

```text
Default
```

Hoặc profile đang được sử dụng.

Chọn:

```text
Features & Layout
```

Trong khu vực **Available Buttons**, kéo các nút Pro cần dùng sang **Current Editor Layout**.

Ví dụ:

* Image Manager Extended.
* Media Manager.
* File Manager.
* Template Manager.
* Captions.
* Columns.
* IFrame.
* Advanced Paste-related functions.

Nhấn Save.

Đây là bước chính thức cần làm khi các nút Pro không xuất hiện sau khi nâng cấp.

## Step 11: Kiểm tra update Pro

Đi đến:

```text
System
→ Update
→ Extensions
```

Nhấn:

```text
Check for Updates
```

Nếu key hợp lệ và subscription còn hiệu lực, các update JCE Pro sau này có thể được cài qua Joomla Updater.

---

# 8. Có thể downgrade Pro về Core không?

Không thể cài JCE Core trực tiếp lên JCE Pro.

Vendor yêu cầu uninstall JCE Pro trước khi cài JCE Core.

Quy trình:

1. Backup Editor Profiles và database.
2. Xác định nội dung đang dùng Pro plugin.
3. Uninstall JCE Pro.
4. Cài JCE Core.
5. Rebuild Update Sites.
6. Kiểm tra các nút Pro đã bị loại bỏ.
7. Kiểm tra article có dùng media hoặc markup phụ thuộc Pro không.

Không thực hiện downgrade trực tiếp trên production mà chưa test staging.

---

# 9. Test sau khi cài đặt thành công

## 9.1 Kiểm tra extension registration

Đi đến:

```text
System
→ Manage
→ Extensions
```

Tìm:

```text
JCE
```

Pass khi:

* `com_jce` tồn tại.
* Editor plugin JCE enabled.
* Không có duplicate extension.
* Phiên bản đúng.
* Core hoặc Pro edition đúng mong đợi.

## 9.2 Kiểm tra JCE Control Panel

Đi đến:

```text
Components
→ JCE Editor
```

Pass khi:

* Control Panel mở được.
* Editor Profiles hiển thị.
* Không có PHP warning.
* Không có JavaScript error.
* Không có lỗi database.

## 9.3 Kiểm tra Default Editor

Đi đến:

```text
System
→ Global Configuration
→ Site
```

Xác nhận:

```text
Default Editor: Editor - JCE
```

## 9.4 Kiểm tra article editor

Đi đến:

```text
Content
→ Articles
→ New
```

Pass khi:

* JCE toolbar xuất hiện.
* Content area nhập được nội dung.
* Bold, italic và heading hoạt động.
* Có thể chuyển Code/Preview nếu profile cho phép.
* Save article thành công.

## 9.5 Test format nội dung

Nhập:

```html
<h2>JCE Test Heading</h2>
<p>This is a <strong>JCE editor test</strong>.</p>
<ul>
    <li>Item one</li>
    <li>Item two</li>
</ul>
```

Thực hiện:

1. Chuyển sang visual mode.
2. Chuyển sang code mode.
3. Chuyển lại visual mode.
4. Save.
5. Mở lại article.

Pass khi markup không bị mất hoặc thay đổi ngoài dự kiến.

## 9.6 Test Image Manager

1. Mở article.
2. Chọn nút Image Manager.
3. Mở một thư mục hợp lệ.
4. Upload file JPG hoặc PNG.
5. Chọn image.
6. Nhập alt text.
7. Insert vào article.
8. Save article.
9. Kiểm tra frontend.

Pass khi:

* Upload thành công.
* Không upload được file ngoài allowlist.
* URL image đúng.
* Alt text được lưu.
* Image hiển thị frontend.

## 9.7 Test File Manager — Pro

Nếu dùng JCE Pro:

1. Thêm File Manager button vào Editor Profile.
2. Mở article.
3. Chọn File Manager.
4. Upload file PDF hợp lệ.
5. Tạo link đến PDF.
6. Save.
7. Kiểm tra frontend.
8. Xác nhận download/open đúng.

Pass khi file không thực thi trên server và đường dẫn được giới hạn đúng thư mục.

## 9.8 Test Media Manager — Pro

1. Thêm Media Manager vào toolbar.
2. Chèn video hoặc audio test.
3. Save.
4. Kiểm tra frontend.
5. Kiểm tra responsive.
6. Kiểm tra browser console.

Pass khi:

* Media hiển thị.
* Không có JavaScript error.
* Không tạo unsafe iframe ngoài allowlist.
* Không phá responsive layout.

## 9.9 Test link browser

1. Chọn một đoạn text.
2. Nhấn Insert/Edit Link.
3. Link đến Joomla article.
4. Link đến menu item.
5. Link đến external URL.
6. Test target và rel attributes.
7. Save.

Pass khi internal link không bị lỗi và external link có attributes đúng chính sách.

## 9.10 Test table

1. Insert table.
2. Thêm row và column.
3. Merge hoặc split cell.
4. Thêm heading row.
5. Save.
6. Kiểm tra frontend mobile.

Pass khi table không phá layout và markup hợp lệ.

## 9.11 Test Editor Profiles

Đi đến:

```text
Components
→ JCE Editor
→ Editor Profiles
```

Tạo hoặc kiểm tra ít nhất:

```text
Administrator profile
Author profile
Frontend editor profile
```

Kiểm tra:

* User Groups.
* Components assignment.
* Device assignment nếu dùng.
* Upload directory.
* Allowed file types.
* Toolbar.
* Editor parameters.

## 9.12 Test quyền theo user group

Tạo test user thuộc nhóm Author hoặc Editor.

Đăng nhập bằng user đó và kiểm tra:

* Có thấy đúng toolbar không.
* Không thấy chức năng dành cho Super User.
* Không duyệt được ngoài thư mục được cấp.
* Không upload được file thực thi.
* Không chỉnh profile.
* Không truy cập JCE component backend nếu không có quyền.

## 9.13 Test upload security

Thử upload các file:

```text
test.jpg
test.png
test.pdf
test.php
test.phtml
test.phar
test.svg
```

Kết quả mong đợi:

* JPG/PNG hợp lệ được phép nếu profile cho phép.
* PDF được phép nếu profile cho phép.
* PHP/PHTML/PHAR phải bị chặn.
* SVG chỉ nên được cho phép khi đã đánh giá rủi ro và có sanitization phù hợp.

Kiểm tra Editor Profile:

```text
Editor Parameters
→ Filesystem
→ Permitted File Extensions
```

Không được có:

```text
php
phtml
phar
cgi
pl
```

## 9.14 Test directory restriction

Trong Editor Profile, đặt thư mục riêng:

```text
images/users/$id
```

hoặc cấu trúc phù hợp project.

Đăng nhập bằng hai user khác nhau.

Pass khi:

* User A không duyệt được thư mục User B.
* Author không duyệt toàn bộ filesystem.
* Không sử dụng `../` để thoát khỏi thư mục.
* Không xóa file ngoài phạm vi được cấp.

## 9.15 Test frontend editing

Nếu website sử dụng frontend editing:

1. Đăng nhập frontend.
2. Mở article được phép edit.
3. Chọn Edit.
4. Kiểm tra JCE load.
5. Upload image theo quyền.
6. Save.
7. Kiểm tra frontend.

Pass khi permissions giống profile dự kiến.

## 9.16 Test third-party components

Mở các component có editor field, ví dụ:

* Contact form builder.
* E-commerce product description.
* Newsletter component.
* Custom component.
* Module Custom HTML.
* Category description.
* User profile editor.

Pass khi JCE load và save đúng trong từng component.

## 9.17 Test Pro buttons sau nâng cấp

Sau Core → Pro, kiểm tra:

* Image Manager Extended.
* File Manager.
* Media Manager.
* Captions.
* Template Manager.
* Các nút khác theo subscription/package.

Nếu nút thiếu:

```text
Components
→ JCE Editor
→ Editor Profiles
→ Profile
→ Features & Layout
```

Kéo nút từ Available Buttons vào Current Editor Layout.

## 9.18 Test browser console

Mở Developer Tools:

```text
F12
→ Console
```

Pass khi không có:

* `Uncaught TypeError`.
* Missing JCE script.
* 404 asset.
* CSP violation.
* MIME type error.
* TinyMCE/JCE conflict.

Kiểm tra Network:

```text
F12
→ Network
```

Filter:

```text
jce
editor
tiny
```

Các asset cần thiết phải trả về HTTP 200.

## 9.19 Test Joomla cache

Clear cache:

```text
System
→ Maintenance
→ Clear Cache
```

Clear expired cache:

```text
System
→ Maintenance
→ Clear Expired Cache
```

Mở lại article editor và xác nhận toolbar vẫn đúng.

## 9.20 Test Joomla Update System

Đi đến:

```text
System
→ Update
→ Extensions
```

Nhấn:

```text
Check for Updates
```

Pass khi:

* Không hiển thị nhầm Core update trên Pro.
* JCE update site enabled.
* Subscription Key được chấp nhận nếu dùng Pro.
* Không xuất hiện lỗi download authorization.

---

# 10. Security checks bắt buộc khi migrate từ site cũ

Nếu Joomla 3 từng dùng JCE `2.9.99.4` hoặc thấp hơn:

## Kiểm tra Editor Profiles lạ

```text
Components
→ JCE Editor
→ Editor Profiles
```

Tìm:

* Profile không nhận diện được.
* Tên random.
* Ordering bất thường.
* Permitted File Extensions chứa `php`.
* Profile cấp cho Public hoặc Guest không hợp lý.

## Kiểm tra file thực thi

```bash
find images media tmp -type f \
  \( -iname "*.php" \
  -o -iname "*.phtml" \
  -o -iname "*.phar" \
  -o -iname "*.php.*" \) \
  -print
```

## Kiểm tra request đáng ngờ

```bash
grep -RIn \
"option=com_jce.*task=profiles.import" \
/var/log/apache2 \
/var/log/nginx \
2>/dev/null
```

Không migrate file hoặc profile đáng ngờ sang Joomla 6.

---

# 11. Troubleshooting

## JCE không xuất hiện trong Default Editor

Kiểm tra:

```text
System
→ Manage
→ Plugins
```

Tìm:

```text
Editor - JCE
```

Đảm bảo plugin được Enabled.

Sau đó clear cache và reload Global Configuration.

## JCE Pro đã cài nhưng không thấy nút Pro

Đi đến:

```text
Components
→ JCE Editor
→ Editor Profiles
→ Default
→ Features & Layout
```

Kéo các nút Pro vào toolbar rồi Save. Đây là hành vi bình thường khi Pro được cài lên Core và profile cũ được giữ nguyên.

## Joomla vẫn hiển thị Core update sau khi cài Pro

Đi đến:

```text
System
→ Update
→ Update Sites
```

Nhấn:

```text
Rebuild
```

Sau đó:

```text
System
→ Update
→ Extensions
→ Check for Updates
```

## Subscription Key không nâng Core thành Pro

Đây không phải lỗi.

Key chỉ cấp quyền cập nhật Pro. Bạn phải download và upload package JCE Pro.

## Discover không tìm thấy JCE

Kiểm tra:

* Manifest có đúng vị trí không.
* File permissions.
* Có copy nhầm package root không.
* Component và plugin có nằm đúng Joomla folder không.

Với JCE, nên chuyển sang:

```text
Install from Folder
```

thay vì tiếp tục copy thủ công.

---

# 12. Production acceptance checklist

## Installation

* [ ] Đúng bản JCE được cài.
* [ ] `com_jce` tồn tại.
* [ ] Editor plugin được enabled.
* [ ] JCE được đặt làm Default Editor.
* [ ] Không có duplicate Core/Pro update site.

## Core functions

* [ ] Article editor load.
* [ ] Format text hoạt động.
* [ ] Code view hoạt động.
* [ ] Preview hoạt động.
* [ ] Image Manager hoạt động.
* [ ] Link browser hoạt động.
* [ ] Table editor hoạt động.
* [ ] Save article không làm mất content.

## Pro functions

* [ ] JCE Pro edition được nhận diện.
* [ ] Subscription Key hợp lệ.
* [ ] Pro buttons được thêm vào profile.
* [ ] Image Manager Extended hoạt động.
* [ ] File Manager hoạt động.
* [ ] Media Manager hoạt động.
* [ ] Joomla Update Manager nhận Pro updates.

## Permissions

* [ ] Super User có đúng quyền.
* [ ] Author chỉ có toolbar cần thiết.
* [ ] Upload directory được giới hạn.
* [ ] PHP/PHTML/PHAR bị chặn.
* [ ] User không truy cập được thư mục khác.
* [ ] Frontend editor có đúng quyền.

## Technical quality

* [ ] Không có PHP warning.
* [ ] Không có JavaScript error.
* [ ] Không có asset 404.
* [ ] Cache không làm hỏng toolbar.
* [ ] JCE hoạt động trong third-party components.
* [ ] Joomla database schema không báo lỗi.

## Security

* [ ] Không có rogue Editor Profile.
* [ ] Không có executable file trong media folders.
* [ ] Không migrate profile chưa kiểm tra.
* [ ] Không dùng JCE `2.9.99.4` hoặc thấp hơn.
* [ ] Backup và rollback đã được kiểm tra.

---

# 13. Kết luận triển khai

```text
Recommended installation:
Download the official JCE package and install it through Joomla's
Upload Package File installer.

Discover:
Use only when the complete extension files have already been copied
into the correct Joomla directories. For JCE, Install from Folder is
safer because JCE is a multi-extension package with installer scripts.

Core to Pro:
Purchase a JCE Pro subscription, download the JCE Pro package, and
install it directly over JCE Core. A Subscription Key alone does not
convert Core to Pro.

After upgrade:
Add the required Pro buttons to each Editor Profile and configure the
Subscription Key for future Joomla updates.

Production approval:
Approve only after editor rendering, upload restrictions, user-group
permissions, Pro features, third-party integrations, update access,
and security checks pass.
```
