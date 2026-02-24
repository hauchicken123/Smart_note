# Flutter Todo App

Phiên bản đơn giản của ứng dụng Todo viết bằng Flutter. README này mô tả cấu trúc mã nguồn, các tệp chính, cách chạy và gợi ý mở rộng.

**Mục lục**
- **Tổng quan**: ý tưởng và hành vi chính.
- **Yêu cầu**: môi trường cần thiết.
- **Chạy ứng dụng**: lệnh nhanh để khởi chạy.
- **Cấu trúc dự án**: mô tả thư mục và các tệp quan trọng.
- **Chi tiết mã nguồn**: giải thích `lib/main.dart` và `lib/todo_item_widget.dart`.
- **Phụ thuộc**: phụ thuộc chính trong `pubspec.yaml`.
- **Gợi ý cải tiến**: lưu trạng thái, i18n, tests.

**Tổng quan**
- Ứng dụng là một Todo list đơn giản cho phép thêm, sửa, xóa và đánh dấu hoàn thành công việc.
- Giao diện sử dụng Material3 (ThemeData với `useMaterial3: true`) và có Tab để lọc `Tất cả`, `Chưa xong`, `Đã xong`.
- Dữ liệu hiện được lưu trong bộ nhớ (một `List<Task>`). Hiện tại không có cơ chế lưu lên đĩa hay database.

**Yêu cầu**
- Flutter SDK tương thích với `sdk: ^3.10.7` (xem `pubspec.yaml`).
- Hệ điều hành: đa nền tảng (Android, iOS, web, desktop) — cần thiết lập cụ thể từng nền tảng để chạy tương ứng.

**Chạy ứng dụng (những lệnh cơ bản)**
```bash
flutter pub get
flutter run
```
Để chọn thiết bị cụ thể: `flutter run -d <device-id>` hoặc dùng `flutter devices` để xem danh sách.

**Cấu trúc dự án (tóm tắt)**
- **lib/**: mã nguồn chính của ứng dụng.
	- [lib/main.dart](lib/main.dart): điểm khởi chạy ứng dụng, chứa `NewTodoApp`, `TodoHome`, model `Task` và hầu hết logic UI/flow.
	- [lib/todo_item_widget.dart](lib/todo_item_widget.dart): widget hiển thị từng mục Todo (Checkbox, text, time, nút Sửa/Xóa).
- **android/**, **ios/**, **web/**, **windows/**, **linux/**, **macos/**: mã và cấu hình nền tảng tương ứng (generated / native).
- **pubspec.yaml**: khai báo tên, môi trường SDK và dependencies.
- **analysis_options.yaml**: quy tắc linting dự án.

**Chi tiết mã nguồn**
- `lib/main.dart`:
	- `Task` model: gồm `id`, `text`, `done` (bool) và `time` (TimeOfDay?). `id` là chuỗi timestamp (microsecondsSinceEpoch).
	- `_TodoHomeState` quản lý trạng thái ứng dụng:
		- `_tasks`: danh sách nhiệm vụ (in-memory).
		- Các phương thức: `_addTaskWithParams`, `_openAddDialog`, `_openAddBottomSheet`, `_editTask`, `_removeAtIndex`, `_toggleDone`, `_confirmDelete`.
		- Lọc/sắp xếp: `_sortedTasks` sắp xếp theo trạng thái (chưa xong lên trước), `_filteredTasks` trả về dựa trên enum `Filter { all, active, done }`.
		- Giao diện hiển thị bằng `Scaffold` + `TabBar` + `ListView.builder`.
		- Thêm/Sửa thực hiện bằng `AlertDialog` (dialog) hoặc `ModalBottomSheet` (bottom sheet) với `TextField` và `showTimePicker` để chọn giờ.
		- Xóa hỗ trợ kéo (Dismissible) kèm xác nhận (`_confirmDelete`).
- `lib/todo_item_widget.dart`:
	- `TodoItemWidget` là `StatelessWidget` nhận props: `id`, `text`, `done`, `time`, `onToggle`, `onEdit`, `onDelete`.
	- Hiển thị `Checkbox`, `ListTile` với `title`, `subtitle` (hiện giờ nếu có) và hai `IconButton` cho Sửa/Xóa.
	- Khi `done == true` sẽ giảm độ mờ (opacity) và gạch ngang text.

**Phụ thuộc (theo `pubspec.yaml`)**
- `flutter` (sdk)
- `cupertino_icons: ^1.0.8`
- `shared_preferences: ^2.1.0` — lưu ý: hiện dự án khai báo `shared_preferences` nhưng trong mã nguồn hiện tại chưa thấy sử dụng. Nếu muốn lưu trạng thái giữa các phiên, cần tích hợp `SharedPreferences` hoặc một giải pháp lưu trữ khác.

**Giải thích chi tiết và hướng dẫn cách làm**

Phần này giải thích cách hoạt động của mã nguồn, từng bước xử lý khi người dùng tương tác, và ý tưởng thiết kế để bạn có thể mở rộng hoặc tái cấu trúc.

- `Task` model
	- Định nghĩa: `class Task { final String id; String text; bool done; TimeOfDay? time; }`.
	- `id` được tạo bằng `DateTime.now().microsecondsSinceEpoch.toString()` để đảm bảo duy nhất.
	- `text` chứa nội dung nhiệm vụ, `done` là trạng thái hoàn thành, `time` là thời gian (tùy chọn) do user chọn.

- Quản lý trạng thái (`_TodoHomeState`)
	- Dữ liệu chính: `_tasks` (List<Task>) lưu toàn bộ nhiệm vụ trong bộ nhớ.
	- `_filter` (enum `Filter`) điều khiển việc hiển thị: `all`, `active`, `done`.
	- Truy xuất danh sách hiển thị:
		- `_sortedTasks`: tạo bản sao của `_tasks` rồi sắp xếp sao cho nhiệm vụ chưa hoàn thành đứng trước.
		- `_filteredTasks`: trả về kết quả dựa trên `_filter` bằng cách lọc `_sortedTasks`.

- Thêm nhiệm vụ
	1. Người dùng bấm nút `+` (floatingActionButton) hoặc nút thêm trên AppBar.
	2. Ứng dụng mở `AlertDialog` (`_openAddDialog`) hoặc `ModalBottomSheet` (`_openAddBottomSheet`) chứa `TextField` và nút `Chọn giờ`.
	3. Sau khi người dùng nhập và nhấn `Thêm`, hàm `_addTaskWithParams(text, sel)` được gọi:
		 - Tạo `Task` mới với `id`, `text`, `time` và chèn vào `_tasks` ở vị trí 0 (để hiện lên đầu danh sách).
	4. Gọi `setState` để cập nhật giao diện và hiển thị `SnackBar` xác nhận.

- Sửa nhiệm vụ
	1. Người dùng nhấn `Sửa` (hoặc tap vào item) => gọi `_editTask(task)`.
	2. Hàm mở `AlertDialog` với `TextField` pre-filled và `showTimePicker` để chỉnh lại giờ.
	3. Khi lưu, cập nhật trực tiếp `_tasks[originalIndex].text` và `.time`, rồi `Navigator.pop(true)` để đóng dialog.
	4. Nếu cập nhật thành công, hiển thị `SnackBar` báo 'Đã cập nhật'.

- Xóa nhiệm vụ
	1. Người dùng có thể kéo (Dismissible) từ phải sang trái hoặc bấm nút `Xóa` trên `TodoItemWidget`.
	2. Trước khi xóa, `_confirmDelete` mở dialog xác nhận; nếu xác nhận, `_removeAtIndex(idx)` được gọi.
	3. `_removeAtIndex` xóa phần tử khỏi `_tasks`, gọi `setState` và hiển thị `SnackBar` thông báo.

- Đánh dấu hoàn thành
	- Khi user tick checkbox, `onToggle` gọi `_toggleDone(task, value)` để thay đổi `task.done` và `setState`.
	- Giao diện `TodoItemWidget` sẽ vẽ lại: gạch ngang và giảm opacity nếu `done == true`.

- Giao diện (UI) chính
	- `Scaffold` chứa `AppBar` với tiêu đề hiển thị tổng số nhiệm vụ và số nhiệm vụ còn lại.
	- `TabBar` (3 tabs) dùng để thay đổi `_filter` khi người dùng chạm.
	- Thân là `ListView.builder` trên `_filteredTasks`; mỗi item là `Dismissible` chứa một `TodoItemWidget`.

- `TodoItemWidget` (tách riêng)
	- Là `StatelessWidget` nhận các callback: `onToggle`, `onEdit`, `onDelete`.
	- Hiển thị `Checkbox` (leading), `title` (nội dung, gạch ngang khi done) và `subtitle` (thời gian nếu có).
	- Hai `IconButton` ở trailing cho Sửa và Xóa; `onTap` trên `ListTile` cũng kích hoạt `onEdit`.

- Lời khuyên tổ chức mã và mở rộng
	- Tách phần quản lý dữ liệu ra lớp riêng (ví dụ `TaskRepository`) để dễ thay thế lưu trữ (in-memory → `SharedPreferences`/`Hive`).
	- Dùng `ChangeNotifier`/`Provider` hoặc `Riverpod` để quản lý trạng thái nếu app phức tạp hơn.
	- Thêm `undo` khi xóa bằng cách lưu tạm `removed` item và hiển thị `SnackBar` với hành động `Undo`.

Phần này nhằm giúp bạn hiểu luồng dữ liệu và vị trí để sửa đổi hay mở rộng các tính năng. Nếu muốn, tôi có thể chuyển `shared_preferences` vào dự án làm ví dụ lưu/khôi phục `_tasks` khi khởi động.


**Tệp tham khảo chính**
- [lib/main.dart](lib/main.dart)
- [lib/todo_item_widget.dart](lib/todo_item_widget.dart)
- [pubspec.yaml](pubspec.yaml)

---
Nếu bạn muốn, tôi có thể:
- Thêm ví dụ lưu dữ liệu với `shared_preferences`.
- Viết tests cơ bản cho màn hình Todo.
- Thêm phần hướng dẫn phát triển cho contributor.

Phiên bản README tạo: 2026-02-05

