/// 할 일의 상태를 나타내는 열거형
enum TodoStatus {
  todo, // 할 일
  urgent, // 급한 일
  inProgress, // 진행 중
  done // 완료
}

/// 할 일을 나타내는 모델 클래스
class Todo {
  final String id; // 할 일의 고유 식별자
  final String creatorCode; // 작성자 코드 - final로 변경
  final String title; // 제목
  final String content; // 내용
  final String assignee; // 담당자
  final String date; // 마감일
  final TodoStatus status; // 상태
  final String tag; // 태그
  final bool isChecked; // 체크 상태

  Todo({
    required this.id,
    required this.creatorCode,
    required this.title,
    required this.assignee,
    required this.content,
    required this.date,
    required this.status,
    this.tag = '',
    this.isChecked = true,
  });

  // 복사본을 생성하되 creatorCode는 변경하지 않는 메서드
  Todo copyWith({
    String? title,
    String? content,
    String? assignee,
    String? date,
    TodoStatus? status,
    String? tag,
    bool? isChecked,
  }) {
    return Todo(
      id: this.id,
      creatorCode: this.creatorCode, // 원래 작성자 코드 유지
      title: title ?? this.title,
      content: content ?? this.content,
      assignee: assignee ?? this.assignee,
      date: date ?? this.date,
      status: status ?? this.status,
      tag: tag ?? this.tag,
      isChecked: isChecked ?? this.isChecked,
    );
  }
}
