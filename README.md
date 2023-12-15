# iRun

iRun은 Flutter로 개발된 러닝 기록 애플리케이션으로 Android와 Web 환경에서 동작시킬 수 있습니다.

동영상 데모를 보려면 (  )여기를 클릭하세요.


---
## 기능
1. 구글 로그인 지원
2. 러닝 기록 측정
3. 각 러닝에 대한 상세 통계 정보 제공
4. 모든 사용자 간에 랭킹 제공
5. 현재 사용자의 업적 기능
6. 음악 기능 제공
7. TTS 기능 제공

---
## 상세 화면
1. 로그인 화면
![login](https://github.com/OSP-ARAM/iRun/assets/138470360/62d1de09-d20c-49e9-bea3-f5b93b3c8915)
2. 메인 화면
![main](https://github.com/OSP-ARAM/iRun/assets/138470360/3cfe31c1-5a7d-43e1-9963-186b68c91435)
3. 러닝 기록 화면
![runRecord](https://github.com/OSP-ARAM/iRun/assets/138470360/8072fe0c-fc72-4351-a1b2-8b975c7437e4)
4. 러닝 기록 중지 화면
![runStop](https://github.com/OSP-ARAM/iRun/assets/138470360/56a0f45a-2a02-4ab1-8162-3b8c03f86e15)
5. 러닝 통계 리스트 화면
![log](https://github.com/OSP-ARAM/iRun/assets/138470360/0568ad00-5cb0-4e1e-9ceb-f5c735982a73)
6. 러닝 통계 상세 화면
![logDetail](https://github.com/OSP-ARAM/iRun/assets/138470360/bd7e2dac-723a-404b-87a1-f94097ecb15f)
7. 음악 화면
![music](https://github.com/OSP-ARAM/iRun/assets/138470360/9c85956a-bb2e-4425-9d8a-18ff97c11086)
8. 랭킹 화면
![ranking](https://github.com/OSP-ARAM/iRun/assets/138470360/49c6b2e3-9de5-4bbf-9cce-9a6690737c70)
9. 업적 화면
![achievement](https://github.com/OSP-ARAM/iRun/assets/138470360/fce8d827-a53b-4983-826e-595884be7910)

---

## Getting Started

아래 설명을 통해 개발 및 테스트 목적으로 로컬 환경에서 iRun 프로젝트 사본을 실행해 볼 수 있습니다.

### 환경 설정

  * 로컬 환경에 최신 버전의 Flutter 및 Dart가 설치되어 있어야 합니다.
  * 로컬 환경에서 최신 버전의 Firebase가 설치되어 있고, 유효한 Firebase 프로젝트가 있어야 합니다.
  * 유효한 API 키가 있는 구글 계정 및 ? 계정이 있어야 합니다.

**Step 1:**

아래 링크를 사용해서 이 레포지토리를 다운로드하거나 복제합니다.:

```
https://github.com/OSP-ARAM/iRun.git
```

**Step 2:**

프로젝트의 루트 경로로 이동해서 콘솔에서 다음 명령을 실행하고, 필요한 종속성을 모두 불러옵니다.:

```
flutter pub get 
```

콘솔에서 다음 명령을 실행하고, Firebase에 로그인해 당신의 프로젝트와 연결해주어야 합니다.

```
firebase login
```

**Step 3:**

각 파일에서 유효한 API 키를 추가해줍니다.

```dart

```
**Step 4:**

콘솔에서 아래 명령어를 실행하고 app을 실행합니다.

```
flutter run
```

