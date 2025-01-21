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

    // 새로운 할 일을 리스트의 시작 부분에 추가
    todos[status]!.insert(0, todo);
  }

  // 할 일의 상태를 변경하고 위치를 이동하는 메서드
  void moveTodo(Todo todo, TodoStatus newStatus, int oldIndex, int newIndex) {
    // 1. 원래 상태의 리스트에서 할 일을 제거하기 전에 복사
    final todoToMove = todos[todo.status]![oldIndex];

    // 2. 원래 상태의 리스트에서 할 일 제거
    todos[todo.status]!.removeAt(oldIndex);

    // 3. 새로운 상태로 이동할 할 일 객체 생성
    final movedTodo = Todo(
      id: todoToMove.id,
      creatorCode: todoToMove.creatorCode,
      title: todoToMove.title,
      content: todoToMove.content,
      assignee: todoToMove.assignee,
      date: todoToMove.date,
      status: newStatus,
      tag: todoToMove.tag,
      isChecked: todoToMove.isChecked,
    );

    // 4. 새로운 상태의 리스트에 할 일 추가
    if (todo.status == newStatus) {
      // 같은 상태 내에서 이동하는 경우
      todos[newStatus]!.insert(newIndex, movedTodo);
    } else {
      // 다른 상태로 이동하는 경우
      if (newIndex >= todos[newStatus]!.length) {
        todos[newStatus]!.add(movedTodo);
      } else {
        todos[newStatus]!.insert(newIndex, movedTodo);
      }
    }

    // 5. 상태 업데이트
    todos[todo.status]!.refresh();
    if (todo.status != newStatus) {
      todos[newStatus]!.refresh();
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

    // copyWith를 사용하여 필요한 필드만 업데이트
    final updatedTodo = todo.copyWith(
        title: newTitle.trim(),
        content: newContent,
        assignee: newAssignee,
        date: newDate,
        status: newStatus,
        tag: todo.tag, // 기존 태그 유지
        isChecked: todo.isChecked // 기존 체크 상태 유지
        );

    // 새로운 상태에 할 일 추가
    todos[newStatus]!.add(updatedTodo);
  }

  // 할 일의 체크 상태를 토글하는 메서드
  void toggleTodoCheck(Todo todo) {
    final currentList = todos[todo.status]!;
    final index = currentList.indexWhere((t) => t.id == todo.id);
    if (index != -1) {
      final updatedTodo = Todo(
        id: todo.id,
        creatorCode: todo.creatorCode,
        title: todo.title,
        content: todo.content,
        assignee: todo.assignee,
        date: todo.date,
        status: todo.status,
        tag: todo.tag,
        isChecked: !todo.isChecked,
      );
      currentList[index] = updatedTodo;
    }
  }
}
