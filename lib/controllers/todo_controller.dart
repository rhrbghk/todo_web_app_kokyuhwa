import 'package:get/get.dart';
import '../models/todo.dart';

// 할 일 관리를 위한 컨트롤러
// GetX를 사용하여 상태 관리를 수행합니다.
class TodoController extends GetxController {
  // 상태별 할 일 목록을 관리하는 맵
  final todos = <TodoStatus, RxList<Todo>>{
    TodoStatus.todo: <Todo>[].obs,
    TodoStatus.urgent: <Todo>[].obs,
    TodoStatus.inProgress: <Todo>[].obs,
    TodoStatus.done: <Todo>[].obs,
  };

  @override
  void onInit() {
    super.onInit();
    // 초기 더미 데이터 추가
    _addDummyData();
  }

  // 더미 데이터 추가 메서드
  void _addDummyData() {
    // 진행중인 할 일
    addTodo(
      '웹 디자인 시안 작성',
      '001',
      content: '메인 페이지와 서브 페이지 디자인 시안 작성하기',
      assignee: '고규화',
      date: '2024-3-25',
      status: TodoStatus.inProgress,
    );

    // 할 일 목록
    addTodo(
      '사용자 피드백 검토',
      '002',
      content: '베타 테스트 사용자들의 피드백 정리 및 개선사항 도출',
      assignee: '김철수',
      date: '2024-3-26',
      status: TodoStatus.todo,
    );

    // 급한 일
    addTodo(
      '서버 업데이트',
      '003',
      content: '보안 패치 및 성능 최적화 작업 진행',
      assignee: '박영희',
      date: '2024-3-24',
      status: TodoStatus.urgent,
    );

    // 할 일 목록
    addTodo(
      'API 문서 작성',
      '001',
      content: 'REST API 엔드포인트 문서화 및 예제 코드 추가',
      assignee: '고규화',
      date: '2024-3-27',
      status: TodoStatus.todo,
    );

    // 완료된 일
    addTodo(
      '코드 리뷰',
      '002',
      content: '팀원들의 PR 검토 및 피드백 제공',
      assignee: '김철수',
      date: '2024-3-23',
      status: TodoStatus.done,
    );
  }

  // 새로운 할 일을 추가하는 메서드
  void addTodo(
    String title,
    String creatorCode, {
    required String content,
    required String assignee,
    required String date,
    TodoStatus status = TodoStatus.todo,
  }) {
    if (title.trim().isEmpty) return;

    final todo = Todo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title.trim(),
      content: content,
      assignee: assignee,
      date: date,
      status: status,
      creatorCode: creatorCode,
    );

    todos[status]!.add(todo);
  }

  // 할 일의 상태를 변경하고 위치를 이동하는 메서드
  void moveTodo(Todo todo, TodoStatus newStatus, int oldIndex, int newIndex) {
    // 현재 상태의 리스트에서 할 일 제거
    final currentList = todos[todo.status]!;
    final index = currentList.indexWhere((t) => t.id == todo.id);
    if (index != -1) {
      currentList.removeAt(index);
    }

    // 새로운 상태로 이동할 할 일 객체 생성
    final movedTodo = Todo(
      id: todo.id,
      title: todo.title,
      content: todo.content,
      assignee: todo.assignee,
      date: todo.date,
      status: newStatus,
      creatorCode: todo.creatorCode,
      isChecked: todo.isChecked,
    );

    // 새로운 위치에 할 일 추가
    if (newIndex >= todos[newStatus]!.length) {
      todos[newStatus]!.add(movedTodo);
    } else {
      todos[newStatus]!.insert(newIndex, movedTodo);
    }
  }

  // 할 일을 삭제하는 메서드
  void deleteTodo(Todo todo) {
    todos[todo.status]!.removeWhere((t) => t.id == todo.id);
  }

  // 할 일을 수정하는 메서드
  void editTodo(
    Todo todo,
    String newTitle,
    TodoStatus newStatus,
    String newContent,
    String newAssignee,
    String newDate,
  ) {
    // 기존 할 일 제거
    todos[todo.status]!.removeWhere((t) => t.id == todo.id);

    // 수정된 할 일 객체 생성
    final updatedTodo = Todo(
      id: todo.id,
      title: newTitle.trim(),
      content: newContent,
      assignee: newAssignee,
      date: newDate,
      creatorCode: todo.creatorCode,
      status: newStatus,
    );

    // 새로운 상태에 할 일 추가
    todos[newStatus]!.add(updatedTodo);
  }

  // 할 일의 체크 상태를 토글하는 메서드
  void toggleTodoCheck(Todo todo) {
    final currentList = todos[todo.status]!;
    final index = currentList.indexWhere((t) => t.id == todo.id);
    if (index != -1) {
      // 체크 상태가 변경된 새로운 할 일 객체 생성
      final updatedTodo = Todo(
        id: todo.id,
        title: todo.title,
        content: todo.content,
        assignee: todo.assignee,
        date: todo.date,
        creatorCode: todo.creatorCode,
        status: todo.status,
        isChecked: !todo.isChecked,
      );
      currentList[index] = updatedTodo;
    }
  }
}
