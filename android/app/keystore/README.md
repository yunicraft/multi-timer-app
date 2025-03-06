# 키스토어 파일 생성

터미널에서 아래 명령어를 실행해 키스토어 파일을 생성합니다.

```
keytool -genkey -v -keystore project-name.jks -keyalg RSA -keysize 2048 -validity 10000 -alias project-name
 ```

project-name 에 프로젝트 이름을 넣어주세요.

명령어를 실행하면 다음 항목들을 입력해야 합니다.
- Keystore Password: 원하는 비밀번호 입력해주세요.
- Alias: 위에 기재한 <project-name> 을 입력해주세요.
- Name, Organization, Location: 이름, 부서, 조직, 위치 등 실제 정보를 입력해주세요.

키를 생성했다면 android/app/keystore/project-name.jks 경로로 옮겨주세요.

# Key Properties 파일 생성

프로젝트의 android 디렉토리에 key.properties 파일을 생성하고 아래 내용을 입력합니다.

```
storePassword=<앞서 설정한 비밀번호>
keyPassword=<앞서 설정한 비밀번호>
keyAlias=<project-name>
storeFile=keystore/<project-name>.jks
```