enum AnalyticsEventType {
  screenView, // 화면 조회
  userAction, // 사용자 행동
  error, // 에러 발생
  performance, // 성능 측정
  conversion; // 전환 (회원가입, 구매 등)

  String get value => name.toLowerCase();
}

enum UserActionType {
  click, // 버튼/항목 클릭
  search, // 검색
  scroll, // 스크롤
  refresh, // 새로고침
  share, // 공유
  input, // 입력
  select, // 선택
  toggle, // 토글
  swipe, // 스와이프
  custom; // 기타 커스텀 액션

  String get value => name.toLowerCase();
}

class AnalyticsParamKey {
  // 공통 파라미터
  static const String screenName = 'screen_name';
  static const String screenClass = 'screen_class';
  static const String timestamp = 'timestamp';

  // 사용자 행동 관련
  static const String actionType = 'action_type';
  static const String actionName = 'action_name';
  static const String actionTarget = 'action_target';
  static const String actionResult = 'action_result';

  // 에러 관련
  static const String errorCode = 'error_code';
  static const String errorMessage = 'error_message';
  static const String errorContext = 'error_context';

  // 성능 관련
  static const String duration = 'duration';
  static const String startTime = 'start_time';
  static const String endTime = 'end_time';
}
