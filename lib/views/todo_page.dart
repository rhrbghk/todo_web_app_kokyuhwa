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
              child: _buildTodoColumn(status, controller),
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
    final textController = TextEditingController(text: todo.title);
    final contentController = TextEditingController(text: todo.content);
    final assigneeController = TextEditingController(text: todo.assignee);
    final dateController = TextEditingController(text: todo.date);
    TodoStatus selectedStatus = todo.status;

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
            onPressed: () => Get.back(),
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
                Get.back();
              }
            },
            child: const Text('수정'),
          ),
        ],
      ),
    );
  }

  // 상태별 할 일 목록 컬럼을 생성하는 메서드
  Widget _buildTodoColumn(TodoStatus status, TodoController controller) {
    final statusLabels = {
      TodoStatus.todo: '할일',
      TodoStatus.urgent: '급한일',
      TodoStatus.inProgress: '진행중',
      TodoStatus.done: '완료',
    };

    return Card(
      margin: const EdgeInsets.all(4.0),
      color: Color(0xFFf7f8fa),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            color: Color(0XFFf7f8fa),
            width: double.infinity,
            child: Text(
              statusLabels[status]!,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: DragTarget<Todo>(
              onWillAccept: (todo) => todo != null,
              onAccept: (todo) {
                final newIndex = controller.todos[status]!.length;
                controller.moveTodo(todo, status, -1, newIndex);
              },
              builder: (context, candidateData, rejectedData) {
                return Obx(
                  () => ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: controller.todos[status]!.length,
                    itemBuilder: (context, index) {
                      final todo = controller.todos[status]![index];
                      return _buildDraggableTodoItem(todo, controller, context);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDraggableTodoItem(
      Todo todo, TodoController controller, BuildContext context) {
    final UserController userController = Get.find<UserController>();

    return Draggable<Todo>(
      data: todo,
      feedback: Material(
        elevation: 4.0,
        child: Container(
          width: 200,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            todo.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
      childWhenDragging: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Color(0xFFf7f8fa),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          todo.title,
          style: const TextStyle(color: Colors.grey),
        ),
      ),
      child: Card(
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
                          _showEditDialog(context, controller, todo);
                        } else if (value == 'delete') {
                          controller.deleteTodo(todo);
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
      ),
    );
  }
}
