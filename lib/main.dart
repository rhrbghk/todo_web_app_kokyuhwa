import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'views/todo_page.dart';
import 'bindings/todo_binding.dart';

/// 앱의 시작점
void main() {
  runApp(const MyApp());
}

/// 메인 앱 위젯
/// GetX를 사용하여 상태 관리 및 라우팅을 구현합니다.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: '투두리스트',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialBinding: TodoBinding(), // 초기 바인딩 설정
      home: const TodoPage(), // 초기 화면 설정
    );
  }
}

class Todo {
  String title;
  bool completed;

  Todo({
    required this.title,
    required this.completed,
  });
}
