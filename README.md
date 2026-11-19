# Pocket Money (money_management)

แอปจัดการการเงินส่วนบุคคลที่เขียนด้วย Flutter ใช้บันทึกรายรับ-รายจ่าย ตั้งงบประมาณ ติดตามบิลที่ต้องจ่าย และสรุปพฤติกรรมการใช้จ่ายเป็นกราฟ ข้อมูลของผู้ใช้แต่ละคนเก็บบน Firebase (Authentication + Cloud Firestore)

<!-- TODO: เพิ่มภาพหน้าจอ (ตอนนี้ยังไม่มีไฟล์ภาพหน้าจอใน repo) -->

## ฟีเจอร์หลัก

- **Onboarding**: หน้าแนะนำแอป 3 หน้า เลื่อนอัตโนมัติ แล้วไปหน้า Login
- **สมัครสมาชิก / เข้าสู่ระบบ**: ใช้ Email + Password ผ่าน Firebase Authentication จำสถานะการล็อกอินไว้ในเครื่องด้วย `shared_preferences`
- **รายการรับ-จ่าย (Transaction)**: เพิ่ม ดู แก้ไข ลบรายการ แยกประเภทรายรับ/รายจ่าย
  - หมวดรายจ่าย: Travel, Home, Bills, Food, Shopping, Pet, Health
  - หมวดรายรับ: Salary, Bonus, Gift
- **งบประมาณ (Budget)**: ตั้งงบตามหมวดหมู่ กำหนดวันเริ่ม-สิ้นสุด ติดตามยอดที่ใช้ไป และแจ้งเตือนเมื่องบใกล้เต็ม
- **บิล (Bill)**: บันทึกบิล วันครบกำหนด ยอดเงิน สถานะ (ยังไม่ชำระ / ชำระแล้ว) และตั้งการแจ้งเตือน
- **หน้า Home**: ภาพรวมรายการพร้อมปฏิทิน (`table_calendar`)
- **Pocket**: สรุปยอดคงเหลือ รายรับ รายจ่าย งบรายเดือน และบิลถัดไป
- **Analysis (Dashboard)**: สรุป Income / Expense / Balance, Budget Summary และกราฟวงกลม Expense Overview (`fl_chart`)
- **การแจ้งเตือนในแอป**: เมื่อมีรายการใหม่ งบใกล้เต็ม หรือบิลใกล้ครบกำหนด แตะเพื่อทำเครื่องหมายว่าอ่านแล้ว ปัดเพื่อลบ หรือลบทั้งหมดได้
- **Setting / Profile**: แก้ไขโปรไฟล์ (Username, Account Name, Birthday) ลบบัญชี และออกจากระบบ

## Tech Stack

| ส่วน | รายละเอียด |
|---|---|
| Framework | Flutter (channel `stable`) ตรวจด้วย `flutter analyze` บน Flutter 3.50.0 / Dart 3.14.0 แล้วไม่พบ error <!-- TODO: ระบุเวอร์ชัน Flutter ที่ใช้พัฒนาจริง --> |
| ภาษา | Dart SDK `^3.7.2` (ตาม `environment` ใน `pubspec.yaml`) |
| Backend | Firebase: Authentication (Email/Password), Cloud Firestore, Hosting (สำหรับเวอร์ชันเว็บ) |

แพ็กเกจหลักที่ใช้ในโค้ด:

| แพ็กเกจ | เวอร์ชัน | ใช้ทำอะไร |
|---|---|---|
| `firebase_core` | ^4.0.0 | เริ่มต้น Firebase |
| `firebase_auth` | ^6.0.0 | สมัครสมาชิก / ล็อกอิน |
| `cloud_firestore` | ^6.0.1 | เก็บข้อมูลผู้ใช้ รายการ งบ บิล และการแจ้งเตือน |
| `shared_preferences` | ^2.2.3 | จำสถานะการล็อกอินในเครื่อง |
| `fl_chart` | ^0.66.0 | กราฟวงกลมในหน้า Analysis |
| `table_calendar` | ^3.0.9 | ปฏิทินในหน้า Home |

แพ็กเกจที่ประกาศใน `pubspec.yaml` แต่ยังไม่ได้ import ในโค้ด: `url_launcher`, `flutter_secure_storage`, `font_awesome_flutter`, `intl`, `month_picker_dialog`, `cupertino_icons`

### โครงสร้างข้อมูลใน Firestore

```
user/{uid}                  ข้อมูลโปรไฟล์ (username, email, ...)
├── transactions/{id}       รายการรับ-จ่าย
├── budgets/{id}            งบประมาณ
├── bills/{id}              บิล
└── notifications/{id}      การแจ้งเตือนในแอป
```

## โครงสร้างโฟลเดอร์

```
lib/
├── main.dart                     # จุดเริ่มแอป: init Firebase, หน้า Onboarding
├── firebase_options.dart         # ค่า Firebase ที่สร้างโดย FlutterFire CLI
├── authenticationService.dart    # สมัคร / ล็อกอิน / ออกจากระบบ
├── notification.dart             # หน้าการแจ้งเตือน
├── login&register/
│   ├── login.dart
│   └── register.dart
├── buttom_navigation/            # หน้าหลักใน bottom navigation
│   ├── homepage.dart             # Home + แถบนำทาง
│   ├── pocket.dart
│   ├── analysis.dart
│   └── setting.dart
├── add_data/                     # ฟอร์มเพิ่มข้อมูล
│   ├── add_transaction.dart
│   ├── add_budget.dart
│   └── add_bill.dart
├── data/                         # หน้ารายการข้อมูล
│   ├── transaction.dart
│   ├── budget.dart
│   └── bill.dart
└── data_detail/                  # หน้ารายละเอียด / แก้ไข
    ├── transaction_detail.dart
    ├── budget_detail.dart
    ├── bill_detail.dart
    └── profile.dart
images/                           # รูปโลโก้ แบนเนอร์ และอวาตาร์
```

## Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) ที่มี Dart `3.7.2` ขึ้นไป
- **Android**: Android Studio + Android SDK และ emulator หรือเครื่องจริงที่เป็น Android 6.0 (API 23) ขึ้นไป (`minSdk = 23`)
- **iOS / macOS** (ต้องใช้ macOS): Xcode และ CocoaPods
- **Web**: Google Chrome
- **ถ้าพัฒนาบน Windows**: ต้องเปิด **Developer Mode** (`start ms-settings:developers`) เพราะ Flutter ต้องใช้ symlink ตอน build plugin ถ้าไม่เปิด `flutter pub get` จะหยุดพร้อมข้อความ "Building with plugins requires symlink support"
- ไม่บังคับ: [Firebase CLI](https://firebase.google.com/docs/cli) และ [FlutterFire CLI](https://firebase.google.com/docs/flutter/setup) ถ้าจะใช้ Firebase project ของตัวเอง หรือจะ deploy เวอร์ชันเว็บ

ตรวจความพร้อมของเครื่องด้วย:

```bash
flutter doctor
```

## การติดตั้งและรัน

repo นี้มีไฟล์ตั้งค่า Firebase (`android/app/google-services.json` และ `lib/firebase_options.dart`) อยู่แล้ว **clone แล้วรันได้เลย** ไม่ต้องตั้งค่าเพิ่ม

```bash
git clone https://github.com/natcha-runsri/Money_Manage_App.git
cd Money_Manage_App
flutter pub get
flutter devices        # ดูอุปกรณ์ / emulator ที่เชื่อมต่ออยู่
flutter run            # หรือ flutter run -d <device_id>
```

แพลตฟอร์มที่ตั้งค่า Firebase ไว้ใน `lib/firebase_options.dart`:

| แพลตฟอร์ม | สถานะ |
|---|---|
| Android (emulator / เครื่องจริง) | ✅ ตั้งค่าแล้ว |
| iOS (Simulator / iPhone) | ✅ ตั้งค่าแล้ว <!-- TODO: ยังไม่ได้ทดสอบรันบน iOS; `IPHONEOS_DEPLOYMENT_TARGET` ตอนนี้คือ 12.0 ซึ่งอาจต่ำกว่าที่ Firebase เวอร์ชันนี้ต้องการ --> |
| Web (Chrome) | ✅ ตั้งค่าแล้ว `flutter run -d chrome` |
| macOS / Windows | ⚙️ มีค่าใน `firebase_options.dart` <!-- TODO: ยืนยันว่ารันได้จริง --> |
| Linux | ❌ ยังไม่รองรับ (`firebase_options.dart` จะ throw `UnsupportedError`) |

### ใช้ Firebase project ของตัวเอง (ไม่บังคับ)

ถ้าต้องการให้แอปเชื่อมกับ Firebase project ของคุณเอง แทนโปรเจกต์ที่ตั้งไว้ใน repo:

1. สร้าง project ใน [Firebase Console](https://console.firebase.google.com/) แล้วเปิดใช้ **Authentication → Email/Password** และ **Cloud Firestore**
2. ติดตั้งและล็อกอิน CLI:
   ```bash
   npm install -g firebase-tools
   firebase login
   dart pub global activate flutterfire_cli
   ```
3. รันที่ root ของโปรเจกต์ เพื่อสร้าง `lib/firebase_options.dart` และ `android/app/google-services.json` ใหม่:
   ```bash
   flutterfire configure
   ```
4. ตั้ง Firestore Security Rules ให้ผู้ใช้เข้าถึงได้เฉพาะ `user/{uid}` ของตัวเอง <!-- TODO: เพิ่มไฟล์ firestore.rules ตัวอย่างใน repo -->

> แอปนี้ไม่ต้องใช้ไฟล์ `.env` หรือ API key อื่นนอกจากค่า Firebase ที่ `flutterfire configure` สร้างให้

## การ Build

```bash
# Android
flutter build apk --release        # ไฟล์ APK: build/app/outputs/flutter-apk/app-release.apk
flutter build appbundle --release  # ไฟล์ AAB สำหรับ Google Play

# iOS (ต้องใช้ macOS + Xcode)
flutter build ios --release

# Web
flutter build web
firebase deploy --only hosting     # deploy โฟลเดอร์ build/web ตาม firebase.json
```

> ตอนนี้ release build ของ Android ยัง sign ด้วย debug key (`signingConfig = signingConfigs.getByName("debug")` ใน `android/app/build.gradle.kts`) ถ้าจะเผยแพร่ต้องสร้าง keystore ของตัวเองตาม [คู่มือของ Flutter](https://docs.flutter.dev/deployment/android#sign-the-app) **และห้าม commit ไฟล์ `key.properties` หรือ `*.jks`** (ไฟล์เหล่านี้อยู่ใน `.gitignore` แล้ว)

## ผู้พัฒนา

- [natcha-runsri](https://github.com/natcha-runsri) <!-- TODO: เพิ่มชื่อจริง / สมาชิกในทีม / รายวิชา (ถ้ามี) -->
