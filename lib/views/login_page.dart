import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/user_controller.dart';
import 'todo_page.dart';

// 로그인 페이지
class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  // 사용자 코드 입력을 위한 컨트롤러
  final TextEditingController codeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final UserController userController = Get.find<UserController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('로그인'),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 사용자 코드 입력 필드
              TextField(
                controller: codeController,
                decoration: const InputDecoration(
                  labelText: '사용자 코드',
                  hintText: '예: 001, 002, 003',
                  border: OutlineInputBorder(),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // 로그인 버튼
              ElevatedButton(
                onPressed: () {
                  if (userController.login(codeController.text.trim())) {
                    Get.off(() => const TodoPage());
                  } else {
                    Get.snackbar(
                      '오류',
                      '잘못된 사용자 코드입니다.',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  }
                },
                child: const Text('입장하기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
