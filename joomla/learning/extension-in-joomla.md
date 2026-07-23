# Extension trong Joomla

## 1. Extension là gì?

**Extension** là phần mở rộng dùng để bổ sung hoặc thay đổi chức năng của website Joomla.

Ví dụ:

- Quản lý bài viết, người dùng và liên hệ.
- Hiển thị menu, banner hoặc form đăng nhập.
- Tích hợp thanh toán, API hoặc công cụ sao lưu.
- Thay đổi giao diện website.
- Cung cấp thêm ngôn ngữ.

Ngay cả nhiều chức năng có sẵn của Joomla cũng được tổ chức dưới dạng extension.

> Không nên nhầm **extension type** với **extension origin** hoặc các màn hình **Install, Manage, Update**.

## 2. Ba khái niệm cần phân biệt

| Khái niệm | Câu hỏi cần trả lời | Ví dụ |
|---|---|---|
| Type | Extension hoạt động theo cơ chế nào? | Component, Module, Plugin |
| Origin | Extension do ai cung cấp? | Joomla Core, Third-party, Custom |
| Management screen | Đang thực hiện thao tác gì? | Install, Manage, Update |

Ngoài ra:

- **Client** cho biết extension chạy ở frontend hay backend.
- **Folder/Group** cho biết plugin thuộc nhóm sự kiện nào.
- **Status** cho biết extension đang được bật hay tắt.

## 3. Joomla 3 có bao nhiêu loại extension?

Joomla 3 có **8 loại extension**:

| # | Type | Tên kỹ thuật thường gặp | Chức năng chính |
|---:|---|---|---|
| 1 | Component | `com_*` | Chức năng nghiệp vụ lớn |
| 2 | Module | `mod_*` | Khối nội dung nhỏ trên trang |
| 3 | Plugin | `plg_*` | Xử lý sự kiện trong hệ thống |
| 4 | Template | Tên template | Giao diện frontend hoặc backend |
| 5 | Language | `en-GB`, `vi-VN` | Gói ngôn ngữ |
| 6 | Library | `lib_*` | Code dùng chung |
| 7 | Package | `pkg_*` | Bộ cài chứa nhiều extension |
| 8 | File | `files_*` | Cài hoặc cập nhật một nhóm file |

### 3.1. Component

Component là chức năng lớn, thường có phần quản trị trong backend và phần hiển thị ở frontend. Có thể xem component như một ứng dụng nhỏ bên trong Joomla.

Ví dụ:

- `com_content`: quản lý bài viết.
- `com_users`: quản lý người dùng.
- `com_contact`: quản lý liên hệ.
- `com_akeeba`: chức năng sao lưu của Akeeba.
- `com_vehicle`: component custom quản lý xe.

### 3.2. Module

Module là một khối nội dung nhỏ được đặt tại một vị trí của template.

Ví dụ:

- Menu.
- Form đăng nhập.
- Banner.
- Danh sách bài viết mới.
- Khối tìm kiếm xe.

Một module extension có thể tạo ra nhiều module instance. Ví dụ website có thể tạo 20 khối Custom HTML từ `mod_custom`, nhưng trong Extension Manager, `mod_custom` vẫn chỉ là một extension.

### 3.3. Plugin

Plugin thực thi khi một sự kiện của Joomla xảy ra, chẳng hạn:

- Người dùng đăng nhập.
- Bài viết được lưu.
- Nội dung được hiển thị.
- Request được khởi tạo.
- Extension được cài đặt.

Các plugin group phổ biến:

| Plugin group | Chức năng |
|---|---|
| `system` | Xử lý sự kiện toàn hệ thống |
| `content` | Xử lý bài viết và nội dung |
| `user` | Xử lý người dùng |
| `authentication` | Xác thực đăng nhập |
| `editors` | Trình soạn thảo |
| `captcha` | CAPTCHA |
| `finder` | Smart Search |

> `Folder = system` không có nghĩa plugin là Joomla Core. Nó chỉ cho biết plugin thuộc nhóm sự kiện hệ thống.

### 3.4. Template

Template quyết định giao diện và bố cục của Joomla:

- **Site Template**: giao diện frontend.
- **Administrator Template**: giao diện backend.

Template có thể chứa override tại:

```text
/templates/template_name/html/
```

Template override là code tùy chỉnh giao diện của component hoặc module, nhưng **không phải một extension riêng**.

### 3.5. Language

Language extension cung cấp file dịch cho Joomla hoặc các extension khác.

Ví dụ:

- `en-GB`: English.
- `vi-VN`: Vietnamese.
- `zh-CN`: Chinese Simplified.

Khi audit website, language extension cũng cần được ghi nhận.

### 3.6. Library

Library chứa code dùng chung cho một hoặc nhiều extension khác, ví dụ framework, API client hoặc helper classes.

Library thường không có trang hiển thị trực tiếp. Tuy nhiên, khi library không tương thích với phiên bản PHP hoặc Joomla mới, các extension phụ thuộc vào nó có thể cùng bị lỗi.

### 3.7. Package

Package là bộ cài có thể chứa nhiều extension:

```text
pkg_example
├── com_example
├── mod_example
├── plg_system_example
└── lib_example
```

Khi làm báo cáo nâng cấp, cần ghi nhận cả package và từng extension con vì mỗi extension con đều có rủi ro tương thích riêng.

### 3.8. File

File extension dùng để cài hoặc cập nhật một nhóm file không thuộc cấu trúc thông thường của component, module hoặc plugin.

Nó có thể chứa:

- Framework files.
- Fonts hoặc assets.
- File hệ thống dùng chung.
- File hỗ trợ cho extension khác.

## 4. Core, Third-party và Custom là gì?

Đây là **nguồn gốc (origin)** của extension, không phải extension type.

| Origin | Ý nghĩa | Ví dụ |
|---|---|---|
| Joomla Core | Có sẵn trong bộ cài Joomla chính thức | `com_content`, `com_users`, `mod_menu` |
| Third-party | Do vendor bên ngoài phát triển và được cài thêm | Akeeba Backup, JCE Editor |
| Custom | Được viết riêng cho website hoặc công ty | `com_dealer`, `mod_vehicle_finder` |
| Unknown – Need verification | Chưa đủ bằng chứng để xác định | Thiếu author, tài liệu và source history |

Bất kỳ extension type nào cũng có thể là Core, Third-party hoặc Custom:

| Extension | Type | Origin |
|---|---|---|
| `com_content` | Component | Joomla Core |
| `com_akeeba` | Component | Third-party |
| `com_dealer` | Component | Custom |
| `mod_menu` | Module | Joomla Core |
| `mod_vehicle_finder` | Module | Custom |
| `plg_system_cache` | Plugin | Joomla Core |
| `plg_system_akeeba` | Plugin | Third-party |

## 5. Cách kiểm tra extension trong Joomla 3 Backend

Đăng nhập Administrator:

```text
https://your-domain.com/administrator
```

Sau đó vào:

```text
Extensions → Manage → Manage
```

Đây là màn hình chính để lấy danh sách extension đã đăng ký. Dùng bộ lọc **Type** để kiểm tra lần lượt:

- Component.
- Module.
- Plugin.
- Template.
- Language.
- Library.
- Package.
- File.

Nên ghi nhận các trường:

- Name.
- Technical Name hoặc Element.
- Type.
- Folder.
- Client.
- Version.
- Author.
- Status.
- Protected.
- Extension ID.

Không nên chỉ kiểm tra menu **Components**, vì menu này không hiển thị đầy đủ module, plugin, template, library và các loại còn lại.

## 6. Cách xác định Core, Third-party và Custom

Không có một dấu hiệu đơn lẻ nào đảm bảo chính xác 100%. Cần kết hợp nhiều bằng chứng.

| Dấu hiệu | Joomla Core | Third-party | Custom |
|---|---|---|---|
| Author | Joomla! Project | Tên vendor bên ngoài | Công ty hoặc developer nội bộ |
| Có trong bộ cài Joomla sạch | Có | Không | Không |
| Protected | Thường có | Thường không | Thường không |
| Update Site | Joomla server | Vendor server | Server nội bộ hoặc không có |
| Documentation | Joomla Docs | Website vendor | Tài liệu nội bộ |
| Technical Name | Tên tiêu chuẩn Joomla | Tên sản phẩm/vendor | Tên dự án/nghiệp vụ |
| Source history | Joomla source | Vendor package | Repository dự án |

### Quy trình xác định an toàn

1. Kiểm tra `Author`, `Version`, `Element` trong **Manage**.
2. So sánh với bộ cài mặc định của đúng phiên bản Joomla.
3. Kiểm tra `Extensions → Manage → Update Sites`.
4. Tìm vendor và tài liệu chính thức.
5. Kiểm tra file manifest XML.
6. Kiểm tra Git history, source repository và tài liệu dự án.
7. Nếu vẫn chưa chắc chắn, đánh dấu `Unknown – Need verification`.

Không nên kết luận chỉ dựa vào:

- Extension ID thấp.
- `Protected = Yes`.
- Plugin folder là `system`.
- Tên extension có chữ `custom`.
- Không có Update Site.

Đây chỉ là dấu hiệu tham khảo.

## 7. Install, Manage và Update có phải extension type không?

**Không.** Đây là các màn hình quản lý extension.

| Màn hình | Chức năng |
|---|---|
| Install | Cài extension mới |
| Manage | Xem và quản lý extension đã đăng ký |
| Update | Hiển thị extension đang có phiên bản mới |
| Discover | Tìm source extension có trên server nhưng chưa được đăng ký |
| Database | Kiểm tra database schema |
| Warnings | Hiển thị cảnh báo cấu hình |
| Install Languages | Cài thêm gói ngôn ngữ |
| Update Sites | Quản lý URL dùng để kiểm tra phiên bản mới |

Luồng thông thường:

```text
Install
  ↓
Extension xuất hiện trong Manage
  ↓
Update Site kiểm tra phiên bản
  ↓
Có phiên bản mới thì extension xuất hiện trong Update
```

Vì vậy:

- **Manage**: danh sách extension đã đăng ký.
- **Update**: chỉ extension đang có bản cập nhật.
- **Install**: nơi cài extension mới.
- **Discover**: tìm extension đã được copy lên server nhưng chưa cài đúng quy trình.

## 8. Cấu trúc report đề xuất

| Extension Name | Technical Name | Type | Client/Folder | Origin | Version | Status | Upgrade Risk |
|---|---|---|---|---|---|---|---|
| Content | `com_content` | Component | Site/Admin | Joomla Core | 3.x | Enabled | Theo quy trình nâng cấp Joomla |
| Akeeba Backup | `com_akeeba` | Component | Administrator | Third-party | 7.x | Enabled | Kiểm tra tương thích từ vendor |
| Vehicle Finder | `mod_vehicle_finder` | Module | Site | Custom | 1.0 | Enabled | Cần review source |
| Custom Tracking | `plg_system_customtracking` | Plugin | `system` | Custom | Unknown | Enabled | Rủi ro cao |

## 9. Checklist audit extension

- [ ] Mở `Extensions → Manage → Manage`.
- [ ] Lọc và kiểm tra đủ 8 extension type.
- [ ] Kiểm tra cả Site và Administrator client.
- [ ] Kiểm tra extension Enabled và Disabled.
- [ ] Ghi nhận Author, Version, Element và Status.
- [ ] Kiểm tra Update Sites.
- [ ] Chạy Discover nhưng không cài ngay khi chưa xác minh.
- [ ] Kiểm tra package và toàn bộ extension con.
- [ ] Kiểm tra template override.
- [ ] Dùng `Unknown – Need verification` khi chưa đủ bằng chứng.

## 10. Công thức ghi nhớ

```text
Type   = Extension hoạt động như thế nào?
Origin = Extension do ai cung cấp?
Client = Extension chạy ở frontend hay backend?
Folder = Plugin thuộc nhóm sự kiện nào?
Status = Extension đang bật hay tắt?
Screen = Bạn đang thực hiện thao tác gì?
```

## Kết luận

Joomla 3 có **8 extension type**: Component, Module, Plugin, Template, Language, Library, Package và File.

Mỗi extension cần được phân loại theo hai cột riêng:

```text
Extension Type + Origin
```

Origin nên dùng một trong bốn giá trị:

- Joomla Core.
- Third-party.
- Custom.
- Unknown – Need verification.

Backend UI giúp lấy danh sách và cung cấp bằng chứng ban đầu. Để xác định chính xác extension custom, cần kiểm tra thêm manifest XML, Update Site, source code, Git history và tài liệu dự án.

## Tài liệu tham khảo

- [Joomla Extension Types](https://docs.joomla.org/Extension_types_%28general_definitions%29)
- [Joomla 3 Extension Manager](https://docs.joomla.org/Help310%3AExtensions_Extension_Manager_Manage)
- [Joomla Manifest Files](https://docs.joomla.org/manifest_files)
- [Joomla Discover](https://docs.joomla.org/Help310%3AExtensions_Extension_Manager_Discover)
