<br>

# 👍🏻iDo

### **사람들과 관심사 또는 취미를 공유해보세요!**
### **다같이 즐길 수 있도록 도와드릴게요!**

<br>

## 📆 프로젝트 기간

2023년 10월 10일 ~ 2023년 11월 17일 (6주)

<br>

## ⭐️ 프로젝트 소개
### 쉽게 모임을 통해 많은 사람들과 함께 취미와 관심사를 즐길 수 있는 커뮤니티 앱
iDo는 카테고리를 통해 좀 더 쉽게 같은 취미를 가진 사람들과 어울릴 수 있습니다. <br>
<br>

### 프로젝트 목표
내성적인 사람을 포함한 2030세대 모두가 어려움 없이 같이 취미를 공유한다는 즐거움을 느낄 수 있도록 기회를 제공하는 것이 목표입니다. <br>

<br>

## 📚 구현 기능
    
0. **공통**
    - [x] 로그인 유저 데이터 동기화
    - [x] 가입 유저 데이터 동기화
    - [x] 이미지 캐싱 작업
    
   <br>

1. **로그인/회원가입 페이지**
    - [x] 아이디 및 비밀번호 비교
    - [x] 이메일 유효성 검사 (중복 가입 방지)
    - [x] 이메일을 이용한 인증번호
    - [x] 비밀번호 유효성 검사 (영문자, 숫자, 특수기호 필수)
    
    <br>
  
2. **홈 페이지**
    - [x] 가입한 모임 목록 표시
    - [x] 가입한 모임으로 이동
    
    <br>
    
3. **카테고리 페이지**
    - [x] 9가지 카테고리 중 1가지 선택
    
    <br>
    
4. **모임 페이지**
    - [x] 모임 커버 이미지, 모임 이름, 모임 소개 표시
    - [x] 가입 멤버 목록
    - [x] 모임장 표시
    - [x] 프로필 이미지 클릭 시, 해당 유저 프로필 확인
    - [x] 모임 생성 
    - [x] 모임 생성 시, 3:2 비율로 자르기
    
    <br>

5. **게시글 페이지**
    - [x] 제목, 내용, 이미지, 작성 시간 표시
    - [x] 게시글 추가/삭제/수정 기능
    - [x] 댓글 추가/삭제/수정 기능
    - [x] 프로필 이미지 클릭 시, 해당 유저 프로필 확인
    - [x] 게시글 신고하기
    - [x] 댓글 신고하기
    
    <br>

6. **마이 프로필 페이지**
    - [x] 나의 프로필 조회
    - [x] 프로필 수정
    - [x] 로그아웃, 서비스 탈퇴
    
    <br>
    
<br>

## 👩🏻‍💻 Contributors

| [홍준영](https://github.com/wnsdud0721) | [김도현](https://github.com/jingni1115) | [강지훈](https://github.com/KangJiHun1028) | [한동연](https://github.com/Direchan) | [이애라](https://github.com/aera11) |
| :----------------------------------: | :---------------------------------------: | :-----------------------------------: | :-----------------------------------: | :------------------------------------: |
|               ☀️ 리더                 |                ️🌙 부리더                    |               🛠️ 개발자                 |                🛠️ 개발자                |                🛠️ 개발자                   |
|       게시글 목록/게시글 생성 및 수정       |                 게시글 상세/댓글            |                 회원가입                 |               모임 생성/수정              |                 홈 화면                    |
|              회원탈퇴                 |                 이미지 캐싱                  |                 로그아웃                  |            이미지 유효성 검사 기능          |                마이 프로필 화면            |
|              신고기능                 |                 신고기능                    |                 카테고리                  |               이미지 편집                |                상단 로고 추가              |

<br>

## ⚙️ <b>Tech Stack</b>

<br>

<img src="https://img.shields.io/badge/Xcode-147EFB?style=for-the-badge&logo=Xcode&logoColor=white"/></a>
<img src="https://img.shields.io/badge/Swift-F05138?style=for-the-badge&logo=Swift&logoColor=white"/></a>
<img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=Firebase&logoColor=white"/></a>

<br>
<div align="left">

## 🏹 사용한 라이브러리

1. [Firebase](https://github.com/firebase/firebase-ios-sdk)
2. [SnapKit](https://github.com/SnapKit/SnapKit)
3. [Tabman](https://github.com/uias/Tabman)
4. [TOCropViewController](https://github.com/TimOliver/TOCropViewController)

<br>

## ⚡️ 라이브러리 사용 이유
   
1. ***Firebase*** <br>
    로그인 및 회원가입 진행 시 `유저의 데이터를 가져오고 비교하기 위해` Authentication에 데이터 동기화를 위해서 사용 <br>
    모임/게시글/댓글 등 `각각 콘텐츠의 CRUD 기능을 위한 데이터를 활용하기 위해` Realtime에 데이터 동기화를 위해서 사용 <br>
    콘텐츠, 유저와 관련된 `이미지를 관리하고 캐싱하기 위해` Storage에 이미지 저장을 위해서 사용 <br>
   
2. ***SnapKit*** <br>
    `코드 기반 UI 작업의 효율성`을 높이기 위해서 사용
    `Auto Layout`을 쉽게 설정하기 위해 사용
   
3. ***Tabman*** <br>
    `상단 탭바 추가`를 위해 사용
   
4. ***TOCropViewController*** <br>
    `이미지 비율을 3:2로 편집`을 쉽게 하기 위해 사용
 
<br>

## 🔫 트러블 슈팅

- [페이지 별 데이터 동기화](https://boundless-periwinkle-f12.notion.site/762b7a714ee34fc1a82876d0ec7ead4e?pvs=4)

- [UI 업데이트](https://boundless-periwinkle-f12.notion.site/UI-72b2cb78789a44feb79eb344af85223f?pvs=4)

- [이미지 비율 및 다운로드 속도](https://boundless-periwinkle-f12.notion.site/0a66bb604b6c467c86b52d78ed5e36e6?pvs=4)

- [기기 별 레이아웃 조정](https://boundless-periwinkle-f12.notion.site/a411a7136c9240d9879d15b7d339eaa0?pvs=4)

<br>
