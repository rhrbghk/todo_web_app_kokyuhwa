import 'package:get/get.dart';
import '../models/user.dart';

// 사용자 관리를 위한 컨트롤러
class UserController extends GetxController {
  // 현재 로그인한 사용자 정보
  final Rx<User?> currentUser = Rx<User?>(null);

  // 유효한 사용자 목록
  final Map<String, String> validUsers = {
    '001': '사용자1',
    '002': '사용자2',
    '003': '사용자3',
  };

  // 로그인 처리 메서드
  bool login(String code) {
    if (validUsers.containsKey(code)) {
      currentUser.value = User(
        code: code,
        name: validUsers[code]!,
      );
      return true;
    }
    return false;
  }

  // 로그아웃 처리 메서드
  void logout() {
    currentUser.value = null;
  }

  // 로그인 상태 확인 메서드
  bool isLoggedIn() => currentUser.value != null;

  // 할 일 수정 권한 확인 메서드
  bool canEditTodo(String creatorCode) {
    return currentUser.value?.code == creatorCode;
  }
}
