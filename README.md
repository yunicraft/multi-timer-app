# timefolio 프로젝트

## 앱 이름 변경
- `앱 이름 변경` 키워드를 검색하여 앱 이름 변경
- `com.moment.timefolio` 키워드를 검색하여 example 은 도메인으로 timefolio 은 프로젝트 이름으로 변경

## 앱 아이콘 적용 방법
- assets/icon/icon.png 파일 추가
- `flutter pub run flutter_launcher_icons` 명령어 실행

## 안드로이드 빌드 캐시 정리 방법
```
flutter clean
flutter pub cache clean
flutter pub get

# Android 빌드 캐시 정리
cd android 
./gradlew cleanBuildCache
./gradlew clean
cd ..
```

## 안드로이드 앱 빌드 명령어
```
flutter clean // 생략 가능
flutter pub get
flutter build appbundle --release
```

## 프로젝트 구조

### tree:
```
lib
├── clients                    # 외부 서비스 클라이언트 (API, 광고, 인증 등)
├── constants.dart            # 전역 상수 정의 (URL, 앱 이름 등)
├── enums.dart               # 전역 열거형 정의
├── main.dart                # 앱의 진입점 및 초기화
├── models                   # 데이터 모델 클래스
├── repositories            # 데이터 저장소 (로컬/원격 데이터 접근 추상화)
├── router.dart             # 앱 라우팅 설정
├── screens                 # 화면 위젯
│   ├── home_screen.dart    # 홈 화면
├── services               # 비즈니스 로직 서비스
├── states                 # 상태 관리 (Provider, Bloc 등)
├── theme                  # 앱 테마 관련
│   ├── app_colors.dart    # 앱 색상 정의
│   └── app_theme.dart     # 앱 테마 설정
└── widgets               # 재사용 가능한 위젯
    ├── back_button_handler.dart  # 뒤로가기 버튼 처리 위젯
```
### 주요 디렉토리 설명:
- clients: 외부 서비스와의 통신을 담당하는 클라이언트 클래스
- models: 앱에서 사용하는 데이터 구조 정의
- repositories: 데이터 접근 계층 (로컬 저장소, API 등)
- screens: 앱의 각 화면을 구성하는 위젯
- services: 비즈니스 로직을 처리하는 서비스 클래스
- states: 앱의 상태 관리 로직
- theme: 앱의 디자인 시스템 정의
- widgets: 여러 화면에서 재사용되는 공통 위젯


# 프롬프트 모음

### 앱스토어 제출 텍스트 작성
```
lib 폴더의 우리 프로젝트 파일을 읽고 우리 서비스의 앱스토어 제출에 필요한 텍스트를 작성해줘.

- 프로모션 텍스트(타깃에게 후킹한 한 문장)
- 설명(제품의 목적(미션), 사용법, 화면 설명)
- 키워드(,로 구분)
- 메모(앱 심사에 도움을 주는 안내사항)
```

### 플레이스토어 제출 텍스트 작성
```
lib 폴더의 우리 프로젝트 파일을 읽고 우리 서비스의 플레이스토어 제출에 필요한 텍스트를 작성해줘.

- 한 줄 설명(타깃에게 후킹한 한 문장)
- 상세 설명(제품의 목적(미션), 사용법, 화면 설명)
- 키워드(,로 구분)
```


지금 태스크 왼쪽에 있는 숫자는 그냥 태스크 순번을 나타내는데 id 로 묶여서 태스크를 이동시킬때 함께 따라가서 혼란을 일으키고 있어. 태스크 아이디와 순번을 분리하고 아이디는 사용자에게 보여지지 않도록 해줘. 그리고 새 태스크 기본값 명칭을 생성할때에도 아이디가 아니라 순번에 따라 매겨지도록 해줘.