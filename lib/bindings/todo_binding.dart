import 'package:get/get.dart';
import '../controllers/todo_controller.dart';
import '../controllers/user_controller.dart';

// 의존성 주입을 위한 바인딩 클래스
class TodoBinding implements Bindings {
  @override
  void dependencies() {
    // TodoController와 UserController를 Get에 등록
    Get.put(TodoController());
    Get.put(UserController());
  }
}
