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

---

# JCE Editor — Feature and Configuration Guide for Joomla 6

## 1. JCE dùng để làm gì?

**JCE – Joomla Content Editor** là trình soạn thảo nội dung WYSIWYG thay thế trình soạn thảo mặc định của Joomla.

WYSIWYG có nghĩa là người dùng chỉnh sửa nội dung trong giao diện gần giống với kết quả được hiển thị ngoài frontend.

JCE thường được sử dụng để:

* Soạn thảo Joomla Articles.
* Soạn nội dung Custom HTML Module.
* Chỉnh sửa mô tả category.
* Soạn nội dung sản phẩm hoặc form trong extension bên thứ ba.
* Upload và chèn hình ảnh.
* Tạo liên kết đến article, menu item, file hoặc website khác.
* Quản lý thư mục và file.
* Chèn bảng, danh sách, media và iframe.
* Chỉnh sửa trực tiếp mã HTML.
* Tạo editor toolbar khác nhau theo từng user group.
* Giới hạn thư mục upload của từng nhóm người dùng.

JCE được xây dựng dựa trên TinyMCE nhưng hoạt động như một editor replacement riêng dành cho Joomla. Joomla Extensions Directory mô tả JCE là editor có khả năng cấu hình cao, hỗ trợ quản lý hình ảnh, file, link, plugin và giao diện quản trị riêng.

Extension family thường gồm:

```text
com_jce
plg_editors_jce
JCE supporting plugins
JCE Pro plugins, nếu sử dụng bản Pro
```

---

# 2. JCE hỗ trợ những gì?

## 2.1 Trình soạn thảo WYSIWYG

JCE hỗ trợ các thao tác soạn thảo cơ bản:

* Bold, italic, underline.
* Heading.
* Paragraph.
* Font formatting.
* Text alignment.
* Ordered và unordered list.
* Blockquote.
* Undo và redo.
* Find và replace.
* Special characters.
* Horizontal line.
* Subscript và superscript.
* Paste nội dung.
* Remove formatting.
* Fullscreen editing.

JCE phù hợp với administrator, editor hoặc content author không muốn viết HTML thủ công.

---

## 2.2 Chế độ Source Code

JCE cho phép chuyển từ giao diện visual sang HTML source code.

Chức năng này dùng để:

* Kiểm tra cấu trúc HTML.
* Chỉnh class.
* Thêm `data-*` attributes.
* Sửa inline styles khi được cho phép.
* Kiểm tra các thẻ bị lồng sai.
* Chèn markup tùy chỉnh.

### Lưu ý bảo mật

Quyền sửa source code không nên cấp cho mọi user. Khi user được phép thêm script hoặc code blocks, họ có thể gây ra XSS hoặc thay đổi hành vi của website.

JCE cảnh báo rằng Code Block nên chỉ được bật cho user hoặc user group đáng tin cậy.

---

## 2.3 Image Manager

JCE Core cung cấp Image Manager để:

* Duyệt thư mục hình ảnh.
* Upload hình ảnh.
* Tạo thư mục.
* Chọn hình ảnh.
* Thêm alt text.
* Đặt width và height.
* Thiết lập margin.
* Thiết lập alignment.
* Tạo liên kết cho hình ảnh.
* Chèn hình ảnh vào content.

Giao diện Image Manager gồm phần thuộc tính hình ảnh và phần File Browser.

---

## 2.4 Image Manager Extended — Pro

JCE Pro bổ sung Image Manager Extended.

Chức năng mạnh hơn gồm:

* Resize ảnh khi upload.
* Crop ảnh.
* Rotate ảnh.
* Tạo thumbnail.
* Thêm watermark.
* Chỉnh sửa ảnh đã upload.
* Tạo popup hoặc link đến ảnh lớn.
* Quản lý ảnh nâng cao.
* Insert nhiều hình ảnh thuận tiện hơn.

Vendor liệt kê Image Manager Extended và Image Editor là một trong các tính năng chính của JCE Pro.

---

## 2.5 File Browser

JCE cung cấp File Browser dùng chung cho các chức năng quản lý media.

File Browser có thể hỗ trợ:

* Duyệt thư mục.
* Upload file.
* Tạo folder.
* Rename.
* Delete.
* Copy hoặc move file, tùy plugin và quyền.
* Giới hạn root directory.
* Giới hạn loại file.
* Giới hạn kích thước file upload.

Đây là chức năng quan trọng đối với bảo mật vì nó kiểm soát phạm vi filesystem mà user có thể truy cập.

---

## 2.6 File Manager — Pro

File Manager trong JCE Pro hỗ trợ:

* Upload tài liệu.
* Tạo link đến PDF, Word, Excel hoặc file khác.
* Hiển thị icon theo file type.
* Hiển thị file size.
* Hiển thị modified date.
* Tạo link download.
* Dùng thuộc tính HTML `download`.
* Embed một số tài liệu bằng iframe.
* Tạo liên kết nhanh đến file trong Joomla content.

Vendor mô tả File Manager là công cụ tạo liên kết đến hình ảnh, tài liệu, media và các loại file phổ biến.

---

## 2.7 Media Manager — Pro

Media Manager hỗ trợ:

* Chèn video.
* Chèn audio.
* Upload media.
* Chèn HTML5 video.
* Chèn HTML5 audio.
* Cấu hình autoplay, controls hoặc preload.
* Chèn external media.
* Quản lý kích thước hiển thị.
* Cấu hình responsive media.
* Chèn một số embed provider được hỗ trợ.

JCE Pro bao gồm Media Manager cùng với Image Manager Extended và File Manager.

---

## 2.8 Link Manager

JCE hỗ trợ tạo và chỉnh sửa link đến:

* Joomla Article.
* Joomla Category.
* Menu Item.
* Contact.
* File.
* Internal URL.
* External URL.
* Email.
* Anchor trong cùng trang.

Có thể cấu hình:

* Link text.
* URL.
* Target.
* Title.
* CSS class.
* `rel` attributes.
* Popup behavior nếu có plugin hỗ trợ.

---

## 2.9 Table Editor

JCE hỗ trợ:

* Tạo table.
* Thêm hoặc xóa row.
* Thêm hoặc xóa column.
* Merge cell.
* Split cell.
* Tạo heading cells.
* Chỉnh width.
* Thêm class.
* Chỉnh cell alignment.
* Chỉnh table properties.

Chức năng này phù hợp cho bảng dữ liệu đơn giản. Với bảng lớn trên mobile, vẫn cần CSS responsive riêng của template.

---

## 2.10 Editor Profiles

Đây là một trong những chức năng mạnh nhất của JCE.

Mỗi Editor Profile có thể có:

* Toolbar riêng.
* Button riêng.
* Upload folder riêng.
* File extension riêng.
* Quyền quản lý file riêng.
* HTML filtering riêng.
* Typography riêng.
* Component assignment riêng.
* User group assignment riêng.

Profile có thể được gán theo:

* Frontend hoặc backend.
* Desktop, tablet hoặc mobile.
* Joomla component.
* User group.
* User cụ thể.
* Kết hợp nhiều điều kiện.

Tài liệu chính thức xác nhận mỗi JCE Profile là một editor instance có layout và parameter riêng, có thể gán theo area, device, component, user group hoặc user.

---

## 2.11 Toolbar tùy chỉnh

Trong mỗi profile, administrator có thể:

* Thêm button.
* Xóa button.
* Di chuyển button.
* Tạo nhiều toolbar row.
* Chỉ cấp Source Code cho user tin cậy.
* Chỉ cấp File Manager cho nhóm cần upload file.
* Ẩn các chức năng không cần thiết.

Tab **Features & Layout** cho phép sắp xếp editor buttons và cấu hình các chức năng như File Browser, Context Menu, Media Support, Preview, Source Code và Markdown trong Pro.

---

## 2.12 Quản lý quyền theo user group

JCE hỗ trợ Joomla ACL trong phần quản trị.

Có thể giới hạn quyền:

* Truy cập JCE Control Panel.
* Quản lý Profiles.
* Cấu hình JCE.
* Cài hoặc quản lý plugin.
* Chỉnh sửa profile.
* Truy cập file browser.
* Upload, rename hoặc delete file.

JCE sử dụng trang Joomla Permissions với các trạng thái Allowed, Denied và Inherit cho từng user group.

---

## 2.13 Filesystem configuration

Trong Editor Profile, filesystem configuration có thể kiểm soát:

* File Directory Path.
* Root folder.
* User-specific folder.
* Allowed file types.
* File size.
* Folder creation.
* File deletion.
* Rename.
* Upload.
* URL format.
* Relative hoặc absolute URL.

Tài liệu JCE chia Editor Parameters thành Cleanup & Output, Typography, Filesystem và Advanced.

---

## 2.14 HTML cleanup và output filtering

JCE có thể xử lý HTML được paste hoặc nhập vào editor:

* Xóa markup không cần thiết.
* Chuẩn hóa HTML.
* Giữ hoặc loại bỏ style.
* Giữ hoặc loại bỏ class.
* Xử lý Word HTML.
* Sử dụng relative URL.
* Kiểm soát valid elements.
* Kiểm soát extended elements.
* Kiểm soát empty elements.

Đây là chức năng hữu ích để tránh nội dung có HTML bẩn khi copy từ Word, Google Docs hoặc website khác.

---

## 2.15 Typography và editor content CSS

JCE có thể load CSS của template hoặc một editor stylesheet riêng để nội dung trong editor gần giống frontend.

Có thể sử dụng để:

* Hiển thị đúng font.
* Hiển thị heading style.
* Hiển thị button class.
* Hiển thị table style.
* Cung cấp class list cho editor.
* Preview nội dung sát với frontend.

---

## 2.16 Markdown — Pro

JCE Pro hỗ trợ một số tính năng Markdown, bao gồm xử lý nội dung Markdown được paste vào editor.

Markdown phù hợp với user muốn nhập nội dung nhanh bằng cú pháp đơn giản.

Trang chính thức của JCE liệt kê khả năng hỗ trợ Markdown trong các tính năng hiện tại.

---

## 2.17 Template Manager — Pro

Template Manager cho phép:

* Tạo content template.
* Tái sử dụng layout HTML.
* Chèn block nội dung chuẩn.
* Chuẩn hóa cấu trúc article.
* Tạo template cho product description.
* Tạo template cho landing-page section.
* Chèn nội dung mặc định.
* Quản lý nhiều template path.

JCE Pro cung cấp Template Manager như một plugin chính thức.

---

## 2.18 IFrames — Pro

IFrames plugin hỗ trợ chèn và cấu hình iframe.

Có thể dùng cho:

* Maps.
* Video embed.
* Calendly.
* External forms.
* Approved third-party content.

Không nên cho user không tin cậy chèn iframe tùy ý vì iframe có thể tạo rủi ro bảo mật hoặc tracking.

---

## 2.19 Captions — Pro

Captions plugin hỗ trợ:

* Thêm caption cho hình ảnh.
* Chỉnh vị trí caption.
* Tạo markup caption nhất quán.
* Thêm title hoặc mô tả ảnh.
* Styling bằng CSS.

---

## 2.20 Microdata — Pro

Microdata plugin hỗ trợ thêm structured data vào nội dung.

Có thể dùng cho:

* Person.
* Organization.
* Product.
* Event.
* Article.
* Các schema types khác tùy plugin.

Cần sử dụng đúng cấu trúc Schema.org. Không nên thêm microdata chỉ để cố tăng SEO mà nội dung thực tế không phù hợp.

---

## 2.21 Media Field

JCE có thể cung cấp hoặc tích hợp media field cho Joomla form.

Chức năng này giúp custom component hoặc form XML sử dụng trình chọn media của JCE thay cho một text field URL đơn giản. Tài liệu chính thức có nhóm riêng cho JCE Media Field và cấu hình media support.

---

## 2.22 Plugin mở rộng

JCE có kiến trúc plugin và hỗ trợ thêm các plugin mở rộng.

Tùy subscription hoặc package, có thể có:

* JCE Pro plugins.
* Joomla integration plugins.
* TinyMCE-related plugins.
* Object storage plugin.
* Font Awesome.
* AI-related plugin.
* MediaBox integration.
* Các plugin khác từ vendor.

Không nên cài mọi plugin chỉ vì đã mua Pro. Chỉ bật plugin thực sự được project sử dụng để giảm attack surface.

---

# 3. JCE mạnh nhất ở điểm nào?

## 3.1 Editor Profiles và phân quyền

Đây là điểm mạnh lớn nhất.

Ví dụ bạn có thể cấu hình:

| User group     | Toolbar         | Upload directory     | Quyền          |
| -------------- | --------------- | -------------------- | -------------- |
| Super Users    | Full toolbar    | `images/`            | Full           |
| Editors        | Content toolbar | `images/content/`    | Upload, rename |
| Authors        | Basic toolbar   | `images/users/{id}/` | Upload only    |
| Frontend users | Minimal toolbar | Không upload         | Text only      |

JCE kiểm tra profile theo thứ tự và sử dụng profile đầu tiên phù hợp với area, device, component hoặc user group.

## 3.2 Quản lý hình ảnh và file

JCE mạnh hơn editor mặc định khi website có nhiều content editor cần:

* Upload ảnh.
* Quản lý folder.
* Resize ảnh.
* Tạo thumbnail.
* Chèn file download.
* Chèn video.
* Giới hạn thư mục.

## 3.3 Tùy biến editor theo component

Có thể tạo riêng:

* Profile cho Joomla Articles.
* Profile cho Custom HTML Modules.
* Profile cho HikaShop.
* Profile cho AcyMailing.
* Profile cho frontend editing.
* Profile cho custom component.

## 3.4 Kiểm soát HTML output

JCE mạnh trong việc:

* Dọn HTML khi paste.
* Kiểm soát thẻ được phép.
* Giữ output nhất quán.
* Tránh markup dư thừa.
* Tạo relative URL.
* Dùng CSS class có kiểm soát.

## 3.5 Khả năng mở rộng

JCE có Core cho nhu cầu cơ bản và Pro cho file/media/image workflow nâng cao.

---

# 4. So sánh JCE Core và JCE Pro

| Chức năng                |    Core | Pro |
| ------------------------ | ------: | --: |
| WYSIWYG editor           |      Có |  Có |
| Source Code              |      Có |  Có |
| Basic Image Manager      |      Có |  Có |
| Link Manager             |      Có |  Có |
| Table Editor             |      Có |  Có |
| Editor Profiles          |      Có |  Có |
| User-group assignment    |      Có |  Có |
| Filesystem restriction   |      Có |  Có |
| Image Manager Extended   |   Không |  Có |
| Resize/crop/rotate image |   Không |  Có |
| Thumbnail/watermark      |   Không |  Có |
| File Manager             |   Không |  Có |
| Media Manager            |   Không |  Có |
| Template Manager         |   Không |  Có |
| Captions                 |   Không |  Có |
| IFrames plugin           |   Không |  Có |
| Microdata                |   Không |  Có |
| Markdown enhancements    | Hạn chế |  Có |

JCE Core là bản miễn phí giới hạn tính năng, còn JCE Pro bổ sung các plugin như Image Manager Extended, Media Manager và File Manager.

---

# 5. Step-by-step setup từng chức năng

## 5.1 Thiết lập JCE làm editor mặc định

1. Đăng nhập Joomla Administrator.
2. Mở:

```text
System
→ Global Configuration
→ Site
```

3. Tìm:

```text
Default Editor
```

4. Chọn:

```text
Editor - JCE
```

5. Nhấn **Save & Close**.
6. Mở:

```text
Content
→ Articles
→ New
```

7. Xác nhận toolbar JCE hiển thị.

### Kiểm tra user override

Nếu một user vẫn thấy TinyMCE:

1. Mở:

```text
Users
→ Manage
→ Chọn user
```

2. Mở **Basic Settings**.
3. Đặt:

```text
Editor: Use Default
```

---

## 5.2 Tạo Editor Profile cho Administrator

### Mục tiêu

Tạo full toolbar dành cho Super Users và Administrators.

### Các bước

1. Mở:

```text
Components
→ JCE Editor
→ Editor Profiles
```

2. Chọn **New** hoặc copy Default profile.
3. Đặt tên:

```text
Administrator Full Editor
```

4. Trong tab **Setup**, cấu hình:

```text
Area: Administrator
Components: All hoặc com_content
User Groups: Super Users, Administrator
Devices: All
```

5. Trong **Features & Layout**, thêm:

* Source Code.
* Preview.
* Image Manager.
* Link.
* Table.
* Fullscreen.
* File Manager nếu dùng Pro.
* Media Manager nếu dùng Pro.
* Template Manager nếu dùng Pro.

6. Trong **Editor Parameters**, cấu hình:

```text
Relative URLs: Yes
Validate HTML: Yes
```

7. Trong plugin parameters, cấu hình file path:

```text
images
```

8. Save.
9. Đưa profile lên trên các profile tổng quát hơn.

### Kết quả

Administrator nhận full toolbar trong backend.

---

## 5.3 Tạo Editor Profile cho Author

### Mục tiêu

Giới hạn quyền của content author.

### Các bước

1. Copy profile Administrator.
2. Đổi tên:

```text
Author Restricted Editor
```

3. Setup:

```text
Area: Administrator hoặc Site
User Groups: Author
Components: com_content
```

4. Xóa khỏi toolbar:

* Source Code.
* IFrame.
* Media Manager nếu không cần.
* File Manager nếu không cần.
* Template Manager.
* Code Blocks.

5. Chỉ giữ:

* Bold.
* Italic.
* Heading.
* Lists.
* Link.
* Basic Image Manager.
* Table nếu cần.
* Undo/redo.

6. Đặt upload folder:

```text
images/authors/$id
```

Cú pháp biến cụ thể cần được kiểm tra trong JCE profile documentation và version đang dùng.

7. Giới hạn file extensions:

```text
jpg,jpeg,png,webp
```

8. Tắt quyền:

* Delete file.
* Rename file.
* Move file.
* Upload SVG.
* Upload document nếu không cần.

9. Save.
10. Đặt profile Author phía trên Default profile nếu điều kiện matching yêu cầu.

### Kết quả

Author chỉ chỉnh nội dung và ảnh trong phạm vi được cấp.

---

## 5.4 Tùy chỉnh toolbar

1. Mở:

```text
Components
→ JCE Editor
→ Editor Profiles
→ Chọn profile
```

2. Mở:

```text
Features & Layout
```

3. Trong **Available Buttons**, tìm button cần dùng.
4. Kéo button vào **Current Editor Layout**.
5. Kéo để thay đổi vị trí.
6. Xóa button không cần khỏi toolbar.
7. Tạo row mới nếu toolbar quá dài.
8. Save.
9. Mở article để kiểm tra.

### Khuyến nghị toolbar cho Editor

```text
Undo | Redo
Bold | Italic
Paragraph Format
Bulleted List | Numbered List
Link | Unlink
Image Manager
Table
Source Code — chỉ dành cho user tin cậy
```

---

## 5.5 Cấu hình Image Manager

1. Mở Editor Profile.
2. Mở:

```text
Plugin Parameters
→ Image Manager
```

3. Đặt thư mục:

```text
File Directory Path: images
```

Hoặc:

```text
images/content
```

4. Cấu hình permitted extensions:

```text
jpg,jpeg,png,gif,webp
```

5. Đặt upload size phù hợp.
6. Bật hoặc tắt:

* Upload.
* Folder creation.
* Rename.
* Delete.
* Copy.
* Move.

7. Không cho phép:

```text
php,phtml,phar,pl,cgi
```

8. Save.
9. Mở article.
10. Nhấn Image Manager.
11. Upload ảnh thử.
12. Thêm alt text.
13. Insert và save article.

### Kết quả mong đợi

* Upload ảnh hợp lệ thành công.
* File thực thi bị chặn.
* User chỉ thấy đúng thư mục.
* URL được tạo đúng.

---

## 5.6 Cấu hình Image Manager Extended — Pro

1. Xác nhận JCE Pro đã được cài.
2. Mở profile.
3. Mở **Features & Layout**.
4. Kéo **Image Manager Extended** vào toolbar.
5. Mở:

```text
Plugin Parameters
→ Image Manager Extended
```

6. Cấu hình:

* Upload directory.
* Allowed image extensions.
* Maximum width.
* Maximum height.
* Upload resize.
* Thumbnail width/height.
* Image quality.
* Watermark nếu dùng.
* Image Editor permissions.

7. Save.
8. Mở article.
9. Upload ảnh lớn.
10. Chọn resize.
11. Crop hoặc rotate.
12. Tạo thumbnail.
13. Insert vào article.

### Kiểm tra

* Ảnh sau resize đúng kích thước.
* Không overwrite file ngoài ý muốn.
* Thumbnail được lưu đúng folder.
* EXIF orientation không làm ảnh bị xoay sai.
* Image quality chấp nhận được.

---

## 5.7 Cấu hình File Manager — Pro

1. Mở profile.
2. Thêm **File Manager** vào toolbar.
3. Mở:

```text
Plugin Parameters
→ File Manager
```

4. Đặt directory:

```text
files
```

hoặc:

```text
images/documents
```

5. Cho phép các file thực sự cần:

```text
pdf,doc,docx,xls,xlsx,ppt,pptx,zip
```

6. Không cho phép file thực thi.
7. Cấu hình:

* Upload.
* Rename.
* Delete.
* Download attribute.
* File icon.
* File size.
* Modified date.
* Embed option.

8. Save.
9. Mở article.
10. Chọn text.
11. Mở File Manager.
12. Upload PDF.
13. Tạo link.
14. Bật download nếu cần.
15. Save article.
16. Test frontend.

### Kết quả

* PDF mở hoặc tải đúng.
* URL không bị 404.
* File extension nguy hiểm bị chặn.
* Author không thấy file ngoài folder được cấp.

---

## 5.8 Cấu hình Media Manager — Pro

1. Thêm **Media Manager** vào profile toolbar.
2. Mở plugin parameters.
3. Cấu hình media folder:

```text
media/videos
```

hoặc thư mục phù hợp project.

4. Chỉ cho phép media cần dùng:

```text
mp4,webm,mp3,ogg
```

5. Cấu hình:

* Controls.
* Autoplay.
* Loop.
* Preload.
* Width/height.
* Responsive behavior.
* External media rules.

6. Save.
7. Mở article.
8. Upload MP4 test.
9. Insert video.
10. Save.
11. Test Chrome, Firefox, Safari và mobile.

### Khuyến nghị

Không bật autoplay có âm thanh. Không cho phép embed tùy ý từ mọi domain.

---

## 5.9 Cấu hình Link Manager

1. Mở profile.
2. Xác nhận Link button có trên toolbar.
3. Mở plugin parameters của Link.
4. Cấu hình:

* Default target.
* Relative URL.
* Link browser.
* Joomla link integration.
* Allowed attributes.
* Default `rel` value cho external links nếu cần.

5. Save.
6. Test link đến:

   * Article.
   * Category.
   * Menu item.
   * PDF.
   * External URL.
   * Email.

### Kiểm tra

* Internal URL không chứa domain cứng nếu dùng relative URL.
* External link hoạt động.
* Không tạo JavaScript URL.
* `target="_blank"` đi cùng `rel` phù hợp theo chính sách project.

---

## 5.10 Cấu hình HTML cleanup

1. Mở profile.
2. Mở:

```text
Editor Parameters
→ Cleanup & Output
```

3. Khuyến nghị:

```text
Validate HTML: Yes
Relative URLs: Yes
Cleanup on Save: Yes
```

4. Cấu hình valid elements theo project.
5. Không cho phép tùy ý:

```text
script
object
embed
```

trừ profile dành cho developer đáng tin cậy.

6. Save.
7. Copy content từ Microsoft Word hoặc Google Docs.
8. Paste vào editor.
9. Chuyển sang Source Code.
10. Kiểm tra markup dư thừa đã được xử lý.

### Lưu ý

Nếu JCE được dùng trong newsletter component, absolute URL có thể cần thiết thay vì relative URL. Tài liệu JCE cũng lưu ý relative URL mặc định phù hợp với website, nhưng có thể cần tắt khi dùng editor cho newsletter.

---

## 5.11 Cấu hình Content CSS và typography

1. Xác định file CSS frontend:

```text
media/templates/site/<template>/css/template.css
```

hoặc custom editor CSS:

```text
media/templates/site/<template>/css/editor.css
```

2. Mở profile.
3. Mở:

```text
Editor Parameters
→ Typography
```

4. Chọn load template CSS hoặc custom CSS.
5. Thêm editor stylesheet path.
6. Cấu hình class list nếu dùng.
7. Save.
8. Mở article.
9. Kiểm tra heading, table, button và font.

### Khuyến nghị

Tạo file `editor.css` riêng, chỉ chứa style cần thiết cho editor. Không nhất thiết load toàn bộ CSS frontend nếu file quá lớn hoặc gây conflict.

---

## 5.12 Cấu hình Table Editor

1. Thêm Table button vào toolbar.
2. Mở article.
3. Chọn Insert Table.
4. Nhập row và column.
5. Chọn heading row.
6. Thêm class:

```text
table
```

hoặc class theo template:

```text
table table-striped
```

7. Save article.
8. Kiểm tra frontend trên mobile.

### Lưu ý

JCE tạo HTML table, nhưng responsive behavior phụ thuộc template CSS.

---

## 5.13 Cấu hình Template Manager — Pro

1. Tạo thư mục template snippets:

```text
images/jce/templates
```

hoặc thư mục theo cấu hình project.

2. Tạo file HTML template, ví dụ:

```html
<section class="content-block">
    <h2>Section title</h2>
    <p>Section content...</p>
</section>
```

3. Mở Editor Profile.
4. Thêm **Template Manager** vào toolbar.
5. Mở plugin parameters.
6. Đặt template directory.
7. Cấu hình insert hoặc replace content behavior.
8. Save.
9. Mở article.
10. Chọn Template Manager.
11. Chọn template.
12. Insert.
13. Thay nội dung placeholder.
14. Save.

### Use case

* Product description.
* News article.
* Campaign page.
* Staff profile.
* FAQ block.
* Call-to-action section.

---

## 5.14 Cấu hình IFrames — Pro

1. Chỉ áp dụng cho trusted profile.
2. Thêm IFrames button.
3. Mở plugin parameters.
4. Tạo allowlist domain, ví dụ:

```text
www.youtube.com
player.vimeo.com
www.google.com
calendly.com
```

5. Không cho arbitrary iframe với Author.
6. Cấu hình:

* Width.
* Height.
* Responsive wrapper.
* Allow attributes.
* Sandbox nếu phù hợp.
* Loading lazy.

7. Save.
8. Chèn iframe test.
9. Kiểm tra frontend và Content Security Policy.

---

## 5.15 Cấu hình Captions — Pro

1. Thêm Captions button.
2. Chèn một hình ảnh.
3. Chọn hình ảnh.
4. Nhấn Captions.
5. Nhập caption.
6. Chọn alignment.
7. Chọn class.
8. Save.
9. Kiểm tra markup và responsive frontend.

---

## 5.16 Cấu hình Markdown — Pro

1. Mở profile.
2. Mở:

```text
Features & Layout
→ Additional Features
```

3. Bật Markdown nếu package hỗ trợ.
4. Save.
5. Paste nội dung:

```markdown
## Heading

- Item 1
- Item 2

**Bold content**
```

6. Kiểm tra nội dung được chuyển đổi đúng.
7. Chuyển sang Source Code để kiểm tra HTML.

---

## 5.17 Cấu hình quyền quản trị JCE

1. Mở:

```text
Components
→ JCE Editor
→ Options
→ Permissions
```

2. Chọn từng user group.
3. Đặt:

```text
Configure: Super Users only
Manage Profiles: Administrators/Super Users
Manage Plugins: Super Users only
Access Component: Selected administrative groups
```

4. Không cấp quyền profile management cho Author hoặc Editor thông thường.
5. Save.
6. Đăng nhập bằng test user.
7. Kiểm tra access.

---

## 5.18 Export và import Editor Profiles

### Export

1. Mở Editor Profiles.
2. Chọn profile.
3. Nhấn **Export**.
4. Lưu file export vào migration repository hoặc secure storage.

### Import

1. Mở Editor Profiles trên Joomla 6.

2. Nhấn **Import**.

3. Chọn profile export.

4. Review toàn bộ:

   * User groups.
   * File directories.
   * Extensions.
   * Toolbar.
   * Components.
   * Permissions.

5. Không publish ngay profile cũ chưa review.

6. Test bằng user riêng.

JCE hỗ trợ tạo, copy, import và export profiles.

---

# 6. Cấu hình đề xuất cho Joomla 6

## Super User Profile

```text
Area: Administrator
User Groups: Super Users
Toolbar: Full
Source Code: Enabled
Image Manager Extended: Enabled
File Manager: Enabled
Media Manager: Enabled
Template Manager: Enabled
Filesystem root: images
Upload: Enabled
Delete/Rename: Enabled
```

## Content Editor Profile

```text
Area: Administrator
User Groups: Editor, Publisher
Toolbar: Content editing tools
Source Code: Optional
Image Manager: Enabled
File Manager: Optional
Filesystem root: images/content
Upload: Enabled
Delete: Limited
Executable files: Blocked
```

## Author Profile

```text
Area: Site and/or Administrator
User Groups: Author
Toolbar: Basic
Source Code: Disabled
IFrames: Disabled
File Manager: Disabled
Filesystem root: images/authors/{user}
Upload: Image only
Delete/Rename: Disabled
```

---

# 7. Quy trình setup tổng thể được đề xuất

```text
1. Install JCE Core hoặc Pro
2. Enable Editor - JCE plugin
3. Set JCE as Default Editor
4. Audit existing JCE profiles
5. Create Super User profile
6. Create Editor profile
7. Create Author profile
8. Configure toolbar for each profile
9. Configure filesystem path
10. Configure permitted file extensions
11. Configure image upload
12. Configure File Manager nếu dùng Pro
13. Configure Media Manager nếu dùng Pro
14. Configure content CSS
15. Configure HTML cleanup
16. Configure Joomla ACL
17. Test each user group
18. Test third-party components
19. Test frontend editing
20. Perform security and upload tests
```

---

# 8. Checklist kiểm thử

## Editor

* [ ] JCE là Default Editor.
* [ ] Toolbar load thành công.
* [ ] Bold, heading, list hoạt động.
* [ ] Source Code hoạt động đúng quyền.
* [ ] Article save không mất content.
* [ ] Copy/paste không tạo HTML bẩn.

## Images

* [ ] Upload JPG, PNG và WebP thành công.
* [ ] Alt text được lưu.
* [ ] Resize hoạt động nếu dùng Pro.
* [ ] Crop và rotate hoạt động nếu dùng Pro.
* [ ] User chỉ thấy đúng directory.

## Files

* [ ] PDF upload thành công nếu được phép.
* [ ] Link download hoạt động.
* [ ] PHP, PHTML và PHAR bị chặn.
* [ ] User không truy cập folder ngoài phạm vi.
* [ ] Delete và rename đúng permission.

## Media

* [ ] MP4 hoạt động.
* [ ] Audio hoạt động.
* [ ] Responsive trên mobile.
* [ ] Không có console error.
* [ ] External embed chỉ từ domain được phép.

## Profiles

* [ ] Super User nhận đúng profile.
* [ ] Editor nhận đúng profile.
* [ ] Author nhận đúng profile.
* [ ] Profile ordering đúng.
* [ ] Không có profile lạ.
* [ ] Không có profile cho phép upload PHP.

## Integration

* [ ] Joomla Articles hoạt động.
* [ ] Custom HTML Module hoạt động.
* [ ] Category Description hoạt động.
* [ ] Frontend Editing hoạt động.
* [ ] Third-party component editor fields hoạt động.

---

# 9. Hạn chế và lưu ý bảo mật

JCE có attack surface đáng kể vì extension có thể quản lý:

* File upload.
* Image upload.
* Folder.
* HTML source.
* Iframe.
* Media.
* Editor profiles.
* User permissions.

Do đó:

* Luôn sử dụng phiên bản mới nhất.
* Không cấp Source Code cho user không tin cậy.
* Không cấp iframe tùy ý.
* Không cho phép PHP hoặc script extension.
* Giới hạn filesystem root.
* Tách profile theo user group.
* Kiểm tra profile ordering.
* Không sử dụng một profile full quyền cho tất cả user.
* Review profile sau khi import từ Joomla 3.
* Kiểm tra server logs và writable directories.

Các phiên bản JCE cũ từng có lỗ hổng nghiêm trọng liên quan đến profile và upload file, vì vậy profile permissions và permitted extensions phải được coi là kiểm tra bắt buộc.

---

# 10. Đánh giá cuối cùng

```text
Primary purpose:
Provide a configurable WYSIWYG editor and advanced image, file, link
and media-management workflow for Joomla content.

Strongest capability:
Editor Profiles. JCE can provide different toolbars, filesystem roots,
upload permissions and HTML rules based on Joomla area, component,
device, user group or individual user.

Core edition:
Suitable for general content editing, basic image management, links,
tables, source editing and editor-profile configuration.

Pro edition:
Recommended when the project requires image editing, file downloads,
video or audio management, reusable content templates, captions,
iframes, microdata or more advanced media workflows.

Joomla 6 recommendation:
Suitable and strongly recommended when the project needs more control
than Joomla's default editor. It must be configured with least-privilege
profiles and strict file-upload restrictions.
```
