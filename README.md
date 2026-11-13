# Study Smart

Study Smart គឺជា Flutter app សម្រាប់ការសិក្សា ដែលមាន Student និង Admin flow។ App ប្រើ Firebase Authentication សម្រាប់ sign in និង Cloud Firestore សម្រាប់ student profiles និង role។

## បច្ចេកវិទ្យា

- Flutter និង Dart (`sdk: ^3.13.7`)
- Firebase Authentication (`firebase_auth`)
- Cloud Firestore (`cloud_firestore`)
- Firebase Core (`firebase_core`)

## Project structure

```text
lib/
├── app.dart
├── main.dart
├── firebase_options.dart
├── core/
│   ├── services/
│   │   └── user_role_service.dart
│   └── utils/
│       ├── auth_validators.dart
│       └── firebase_error_message.dart
├── features/
│   ├── admin/
│   │   └── presentation/
│   │       └── admin_dashboard_screen.dart
│   ├── auth/
│   │   └── presentation/
│   │       ├── admin_login_screen.dart
│   │       ├── auth_gate.dart
│   │       ├── landing_screen.dart
│   │       ├── student_login_screen.dart
│   │       └── student_register_screen.dart
│   └── student/
│       └── presentation/
│           ├── student_dashboard_screen.dart
│           └── pages/
│               ├── lessons_page.dart
│               ├── progress_page.dart
│               ├── quizzes_page.dart
│               ├── settings_page.dart
│               ├── student_home_page.dart
│               ├── student_profile_page.dart
│               └── subject_list_page.dart
└── shared/
    └── widgets/
        └── stat_card.dart

firestore.rules
firebase.json
test/
└── widget_test.dart
```

### តួនាទីឯកសារសំខាន់ៗ

- `lib/main.dart` ចាប់ផ្ដើម Flutter និង initialize Firebase។
- `lib/app.dart` កំណត់ `StudySmartApp` និង export screens/helpers ដើម្បីរក្សា imports។
- `lib/core/services/user_role_service.dart` អាន និងផ្ទៀងផ្ទាត់ role របស់ user ពី `users/{uid}`។
- `lib/core/utils/` មាន Gmail validation និងការបម្លែង Firebase errors ទៅជាសារបង្ហាញ។
- `lib/features/auth/` មាន landing, student/admin login, registration និង auth gate។
- `lib/features/student/` មាន student dashboard និងទំព័រ Home, Subjects, Lessons, Quizzes, Progress, Profile និង Settings។
- `lib/features/admin/` មាន admin dashboard និងការអាន student records។
- `lib/shared/widgets/` មាន widget ដែលប្រើរួម ដូចជា `StatCard`។
- `firestore.rules` កំណត់សិទ្ធិអាន/សរសេរ Firestore។ `firebase.json` ភ្ជាប់ Firebase CLI ទៅ rules file នេះ។

## ដំណើរការកម្មវិធី

1. `main.dart` initialize Firebase ដោយប្រើ `DefaultFirebaseOptions`។
2. `AuthGate` ស្តាប់ Firebase Authentication state។
3. បន្ទាប់ពី sign in, app អាន `users/{uid}.role`។
4. `role: student` បើក Student Dashboard; `role: admin` បើក Admin Dashboard។
5. Account ដែលគ្មាន profile ឬមាន role មិនត្រឹមត្រូវ នឹងមិនអាចចូល dashboard បាន។

## រៀបចំ Firebase

1. បង្កើត ឬជ្រើស Firebase project ហើយភ្ជាប់ Flutter platforms ជាមួយ Firebase។
2. នៅ Firebase Authentication បើក **Email/Password** sign-in provider។
3. បង្កើត admin account នៅ **Authentication → Users**។ Demo email អាចប្រើ `admin@gmail.com`; កំណត់ password នៅ Firebase Console ហើយកុំដាក់ password ក្នុង source code ឬ README។
4. ចម្លង UID របស់ admin account។
5. នៅ Cloud Firestore បង្កើត collection `users` និង document ដែល ID ស្មើ UID នោះ។ បន្ថែម fields យ៉ាងហោចណាស់៖

   | Field | Type | Value |
   | --- | --- | --- |
   | `uid` | string | UID របស់ Firebase Authentication account |
   | `email` | string | Email របស់ admin |
   | `role` | string | `admin` |

6. ពិនិត្យ Firestore Rules នៅ Firebase Console ថាត្រូវនឹង `firestore.rules` របស់ project។ Deploy rules បន្ទាប់ពី login Firebase CLI និងជ្រើស project ត្រឹមត្រូវ៖

   ```bash
   firebase deploy --only firestore:rules
   ```

Student registration បង្កើត `users/{uid}` ដោយ `role: student` និង profile fields ដូចជា `fullName`, `age`, `studentCode`, `preferredLanguage` និង `createdAt`។

### សុវត្ថិភាព

- Password ត្រូវគ្រប់គ្រងដោយ Firebase Authentication; កុំរក្សាទុក password ក្នុង Firestore, source code ឬ repository។
- Firestore Rules បច្ចុប្បន្នអនុញ្ញាតឲ្យ user បង្កើតតែ student profile និងមិនអនុញ្ញាតឲ្យ user កែ `role` របស់ខ្លួន។
- Admin profile គួរបង្កើតដោយផ្ទាល់តាម Firebase Console ឬ trusted server/Admin SDK; កុំបន្ថែមមុខងារ client ដែលអាចផ្ដល់ `role: admin`។
- Rules ក្នុង repository មានប្រសិទ្ធភាពលើ Firebase តែបន្ទាប់ពី deploy រួច។ កុំប្រើ permissive rules ដូចជា allow read/write to everyone។
- Firebase client configuration មិនមែនជាកន្លែងរក្សា password ឬ service-account private key ទេ។ កុំដាក់ service-account key ក្នុង Flutter app។
- Demo password គួររក្សាទុកក្រៅ repository ហើយប្ដូរទៅ password ខ្លាំង ប្រសិនបើ app នឹងប្រើជាមួយទិន្នន័យពិត។

## ដំឡើង និងរត់

ត្រូវមាន Flutter SDK និង Firebase configuration សម្រាប់ platform ដែលចង់រត់។

```bash
flutter pub get
flutter run
```

ដើម្បីរត់ជា Web នៅ Chrome៖

```bash
flutter run -d chrome
```

## ពិនិត្យកូដ

```bash
flutter analyze
flutter test
```

## កែ Firebase project

បើប្ដូរ Firebase project ឬបន្ថែម platform សូមកំណត់ Firebase configuration ថ្មីសម្រាប់ platform នោះ និងធ្វើបច្ចុប្បន្នភាព `lib/firebase_options.dart` និងឯកសារ platform ដែល Firebase ត្រូវការ។ កុំដាក់ private credentials ឬ service-account keys ក្នុង repository។
