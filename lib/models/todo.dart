/// 할 일의 상태를 나타내는 열거형
enum TodoStatus {
  todo, // 할 일
  urgent, // 급한 일
  inProgress, // 진행 중
  done // 완료
}

/// 할 일을 나타내는 모델 클래스
class Todo {
  String id; // 할 일의 고유 식별자
  String title; // 제목
  String content; // 내용
  String assignee; // 담당자
  String date; // 마감일
  TodoStatus status; // 상태
  String creatorCode; // 작성자 코드
  String tag; // 태그
  bool isChecked; // 체크 상태

  Todo({
    required this.id,
    required this.title,
    required this.creatorCode,
    required this.assignee,
    required this.content,
    required this.date,
    this.status = TodoStatus.todo,
    this.tag = '',
    this.isChecked = true,
  });
}
