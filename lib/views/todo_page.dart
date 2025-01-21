import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/todo_controller.dart';
import '../models/todo.dart';
import '../controllers/user_controller.dart';

// 할 일 목록을 표시하는 메인 페이지
class TodoPage extends StatelessWidget {
  const TodoPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 컨트롤러 및 텍스트 컨트롤러 초기화
    final TodoController controller = Get.find<TodoController>();
    final UserController userController = Get.find<UserController>();
    final TextEditingController textController = TextEditingController();
    final TextEditingController tagController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        // 로그인 상태에 따라 다른 제목 표시
        title: Obx(() => Text(userController.isLoggedIn()
            ? '${userController.currentUser.value?.name}'
            : '투두리스트')),
        centerTitle: true,
        actions: [
          // 로그인/로그아웃 버튼
          Obx(() => IconButton(
                icon: Icon(
                    userController.isLoggedIn() ? Icons.logout : Icons.login),
                onPressed: () {
                  if (userController.isLoggedIn()) {
                    userController.logout();
                    Get.offAll(() => const TodoPage());
                  } else {
                    _showLoginDialog(context);
                  }
                },
              )),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        // 상태별 할 일 목록 표시
        child: Row(
          children: TodoStatus.values.map((status) {
            return Expanded(
              child: _buildTodoColumn(context, status, controller),
            );
          }).toList(),
        ),
      ),
      // 로그인 상태일 때만 할 일 추가 버튼 표시
      floatingActionButton: Obx(() => userController.isLoggedIn()
          ? FloatingActionButton(
              onPressed: () {
                _showAddDialog(
                    context, controller, textController, tagController);
              },
              child: const Icon(Icons.add),
            )
          : const SizedBox.shrink()),
    );
  }

  // 로그인 다이얼로그를 표시하는 메서드
  void _showLoginDialog(BuildContext context) {
    final TextEditingController codeController = TextEditingController();
    final UserController userController = Get.find<UserController>();

    Get.dialog(
      AlertDialog(
        title: const Text('로그인'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: codeController,
              decoration: const InputDecoration(
                labelText: '사용자 코드',
                hintText: '예: 001, 002, 003',
                border: OutlineInputBorder(),
              ),
              textAlign: TextAlign.center,
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              if (userController.login(codeController.text.trim())) {
                Get.back();
              } else {
                Get.snackbar(
                  '오류',
                  '잘못된 사용자 코드입니다.',
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            child: const Text('로그인'),
          ),
        ],
      ),
    );
  }

  // 할 일 추가 다이얼로그를 표시하는 메서드
  void _showAddDialog(
      BuildContext context,
      TodoController controller,
      TextEditingController textController,
      TextEditingController tagController) {
    final UserController userController = Get.find<UserController>();
    final TextEditingController contentController = TextEditingController();
    final TextEditingController assigneeController = TextEditingController();
    final TextEditingController dateController = TextEditingController();
    TodoStatus selectedStatus = TodoStatus.todo;

    Get.dialog(
      AlertDialog(
        title: const Text('할 일 추가'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: textController,
              decoration: const InputDecoration(
                labelText: '제목',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: assigneeController,
              decoration: const InputDecoration(
                labelText: '담당자',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: contentController,
              decoration: const InputDecoration(
                labelText: '내용',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: dateController,
              decoration: const InputDecoration(
                labelText: '날짜',
                border: OutlineInputBorder(),
              ),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (date != null) {
                  dateController.text =
                      "${date.year}-${date.month}-${date.day}";
                }
              },
              readOnly: true,
            ),
            const SizedBox(height: 16),
            StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    DropdownButtonFormField<TodoStatus>(
                      value: selectedStatus,
                      decoration: const InputDecoration(
                        labelText: '상태',
                        border: OutlineInputBorder(),
                      ),
                      items: TodoStatus.values.map((status) {
                        final labels = {
                          TodoStatus.todo: '할일',
                          TodoStatus.urgent: '급한일',
                          TodoStatus.inProgress: '진행중',
                          TodoStatus.done: '완료',
                        };
                        return DropdownMenuItem(
                          value: status,
                          child: Text(labels[status]!),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => selectedStatus = value!);
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              if (textController.text.isNotEmpty &&
                  assigneeController.text.isNotEmpty &&
                  contentController.text.isNotEmpty &&
                  dateController.text.isNotEmpty) {
                controller.addTodo(
                  textController.text,
                  userController.currentUser.value!.code,
                  content: contentController.text,
                  assignee: assigneeController.text,
                  date: dateController.text,
                  status: selectedStatus,
                );
                Get.back();
              }
            },
            child: const Text('추가'),
          ),
        ],
      ),
    );
  }

  // 할 일 수정 다이얼로그를 표시하는 메서드
  void _showEditDialog(
      BuildContext context, TodoController controller, Todo todo) {
    // TextEditingController 인스턴스 생성
    final textController = TextEditingController(text: todo.title);
    final contentController = TextEditingController(text: todo.content);
    final assigneeController = TextEditingController(text: todo.assignee);
    final dateController = TextEditingController(text: todo.date);
    TodoStatus selectedStatus = todo.status;

    // 다이얼로그가 닫힐 때 컨트롤러들을 dispose
    void disposeControllers() {
      textController.dispose();
      contentController.dispose();
      assigneeController.dispose();
      dateController.dispose();
    }

    Get.dialog(
      AlertDialog(
        title: const Text('할 일 수정'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: textController,
              decoration: const InputDecoration(
                labelText: '할 일',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: contentController,
              decoration: const InputDecoration(
                labelText: '내용',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: assigneeController,
              decoration: const InputDecoration(
                labelText: '담당자',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: dateController,
              decoration: const InputDecoration(
                labelText: '날짜',
                border: OutlineInputBorder(),
              ),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (date != null) {
                  dateController.text =
                      "${date.year}-${date.month}-${date.day}";
                }
              },
              readOnly: true,
            ),
            const SizedBox(height: 16),
            StatefulBuilder(
              builder: (context, setState) {
                return DropdownButtonFormField<TodoStatus>(
                  value: selectedStatus,
                  decoration: const InputDecoration(
                    labelText: '상태',
                    border: OutlineInputBorder(),
                  ),
                  items: TodoStatus.values.map((status) {
                    final labels = {
                      TodoStatus.todo: '할일',
                      TodoStatus.urgent: '급한일',
                      TodoStatus.inProgress: '진행중',
                      TodoStatus.done: '완료',
                    };
                    return DropdownMenuItem(
                      value: status,
                      child: Text(labels[status]!),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => selectedStatus = value!);
                  },
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              disposeControllers(); // 취소 시 컨트롤러 정리
              Get.back();
            },
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              if (textController.text.isNotEmpty &&
                  contentController.text.isNotEmpty &&
                  assigneeController.text.isNotEmpty &&
                  dateController.text.isNotEmpty) {
                controller.editTodo(
                  todo,
                  textController.text,
                  selectedStatus,
                  contentController.text,
                  assigneeController.text,
                  dateController.text,
                );
                disposeControllers(); // 수정 완료 시 컨트롤러 정리
                Get.back();
              }
            },
            child: const Text('수정'),
          ),
        ],
      ),
    ).then((_) => disposeControllers()); // 다이얼로그가 어떤 방식으로든 닫힐 때 컨트롤러 정리
  }

  // 상태별 할 일 목록 컬럼을 생성하는 메서드
  Widget _buildTodoColumn(
      BuildContext context, TodoStatus status, TodoController controller) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _getStatusTitle(status),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: DragTarget<Map<String, dynamic>>(
                onWillAccept: (data) => true,
                onAcceptWithDetails: (details) {
                  final data = details.data;
                  final todo = data['todo'] as Todo;
                  final oldIndex = data['index'] as int;

                  // 드롭된 위치의 Y 좌표를 기준으로 새로운 인덱스 계산
                  final RenderBox box = context.findRenderObject() as RenderBox;
                  final localPosition = box.globalToLocal(details.offset);
                  final height = box.size.height;

                  // 상대적 위치에 따라 인덱스 계산 (0~1 사이의 값)
                  final relativePosition = localPosition.dy / height;
                  final listLength = controller.todos[status]!.length;
                  final newIndex = (relativePosition * listLength).round();

                  // 범위를 벗어나지 않도록 조정
                  final adjustedNewIndex = newIndex.clamp(0, listLength);

                  controller.moveTodo(todo, status, oldIndex, adjustedNewIndex);
                },
                builder: (context, candidateData, rejectedData) {
                  return Obx(
                    () => ListView.builder(
                      itemCount: controller.todos[status]!.length,
                      itemBuilder: (context, index) {
                        final todo = controller.todos[status]![index];
                        return Draggable<Map<String, dynamic>>(
                          data: {
                            'todo': todo,
                            'index': index,
                          },
                          feedback: Material(
                            elevation: 4.0,
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.2,
                              padding: const EdgeInsets.all(8.0),
                              color: Colors.white.withOpacity(0.9),
                              child: _buildTodoCard(todo, context),
                            ),
                          ),
                          childWhenDragging: Opacity(
                            opacity: 0.3,
                            child: _buildTodoCard(todo, context),
                          ),
                          child: _buildTodoCard(todo, context),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 상태에 따른 제목을 반환하는 헬퍼 메서드
  String _getStatusTitle(TodoStatus status) {
    switch (status) {
      case TodoStatus.todo:
        return '할 일';
      case TodoStatus.urgent:
        return '급한 일';
      case TodoStatus.inProgress:
        return '진행 중';
      case TodoStatus.done:
        return '완료';
    }
  }

  Widget _buildTodoCard(Todo todo, BuildContext context) {
    final UserController userController = Get.find<UserController>();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    todo.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (userController.canEditTodo(todo.creatorCode) &&
                    userController.isLoggedIn())
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_horiz),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('수정'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red, size: 20),
                            SizedBox(width: 8),
                            Text('삭제', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showEditDialog(
                            context, Get.find<TodoController>(), todo);
                      } else if (value == 'delete') {
                        Get.find<TodoController>().deleteTodo(todo);
                      }
                    },
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              todo.content,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '마감일: ${todo.date}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
                Text(
                  '담당자: ${todo.assignee}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
