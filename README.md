# Blog Bloom

A beautiful, feature-rich blog application built with **Flutter** and **Supabase**, designed using **Clean Architecture** principles.

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)
![BLoC](https://img.shields.io/badge/bloC-8B0000.svg?style=for-the-badge&color=blue)
![Clean Architecture](https://img.shields.io/badge/Clean%20Architecture-000000?style=for-the-badge)

---

## 🚀 Features

- **Clean Architecture & SOLID Principles**: Modular and testable code structure (Domain, Data, Presentation).
- **State Management**: Robust state handling using `flutter_bloc` and `Cubit`.
- **Authentication**: Secure user sign-up and login powered by **Supabase Auth**.
- **Blog Management**: Create, read, update, and delete blogs with rich content.
- **Image Uploads**: Seamless image handling associated with blog posts.
- **Offline Support**: Local caching using **Hive** to keep content accessible without internet.
- **Functional Error Handling**: Type-safe error handling with `fpdart` (`Either`, `Option`).
- **Reliable Connectivity**: Smart network handling using `internet_connection_checker_plus`.

---

## 🛠️ Tech Stack & Dependencies

- **Core**: [Flutter](https://flutter.dev/), [Dart](https://dart.dev/)
- **State Management**: [`flutter_bloc`](https://pub.dev/packages/flutter_bloc)
- **Backend / BaaS**: [`supabase_flutter`](https://pub.dev/packages/supabase_flutter)
- **Dependency Injection**: [`get_it`](https://pub.dev/packages/get_it)
- **Functional Programming**: [`fpdart`](https://pub.dev/packages/fpdart)
- **Local Storage**: [`hive`](https://pub.dev/packages/hive)
- **Network Check**: [`internet_connection_checker_plus`](https://pub.dev/packages/internet_connection_checker_plus)
- **Validation**: [`form_validation`](https://pub.dev/packages/form_validation) (Custom implementation)

---

## 📂 Architecture Overview

This project follows the **Clean Architecture** pattern to separate concerns and ensure scalability.

```
lib/
├── core/                    # Shared functionality (Constants, Errors, UseCases, Widgets)
├── features/                # Feature-based modules
│   ├── auth/                # Authentication Feature
│   │   ├── data/            # Repositories & Data Sources
│   │   ├── domain/          # Entities, Use Cases & Repository Interfaces
│   │   └── presentation/    # BLoCs & UI Pages
│   └── blog/                # Blog Feature (CRUD)
├── init_dependencies.dart   # Dependency Injection Setup
└── main.dart                # Application Entry Point
```

---

## 🏃‍♂️ Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.
- A [Supabase](https://supabase.com/) project set up.

### Installation

1.  **Clone the repository**:
    ```bash
    git clone https://github.com/hitesh-yadav2801/blog_bloom.git
    cd blog_bloom
    ```

2.  **Install dependencies**:
    ```bash
    flutter pub get
    ```

3.  **Configure Environment**:
    - Create a secrets file (e.g., `lib/core/secrets/app_secrets.dart`) or use environment variables.
    - Add your Supabase URL and Anon Key:
      ```dart
      class AppSecrets {
        static const supabaseUrl = 'YOUR_SUPABASE_URL';
        static const supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
      }
      ```

4.  **Run the App**:
    ```bash
    flutter run
    ```
