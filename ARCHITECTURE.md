# Blog Bloom - Architecture & Design Documentation

A comprehensive guide to the project architecture, design patterns, and conventions used in this Flutter application.

---

## Table of Contents

1. [Architecture Overview](#1-architecture-overview)
2. [Layer Structure](#2-layer-structure)
3. [State Management](#3-state-management)
4. [Dependency Injection](#4-dependency-injection)
5. [Error Handling](#5-error-handling)
6. [Key Dependencies](#6-key-dependencies)
7. [Design Principles](#7-design-principles)
8. [Naming Conventions](#8-naming-conventions)
9. [New Feature Template](#9-new-feature-template)

---

## 1. Architecture Overview

This project follows **Clean Architecture** with clear separation into three layers:

```
lib/
├── core/                    # Shared/Core functionality
│   ├── common/              # Shared entities, cubits, widgets
│   │   ├── cubits/          # Global state cubits (e.g., AppUserCubit)
│   │   ├── entities/        # Shared domain entities
│   │   └── widgets/         # Reusable UI components
│   ├── constants/           # App-wide constants
│   ├── error/               # Exception & Failure classes
│   ├── network/             # Network connectivity checker
│   ├── secrets/             # API keys/secrets (gitignored)
│   ├── theme/               # App theming (colors, themes)
│   ├── usecase/             # Base UseCase contract
│   └── utils/               # Utility functions
│
├── features/                # Feature modules
│   ├── auth/                # Authentication feature
│   │   ├── data/            # Data Layer
│   │   ├── domain/          # Domain Layer
│   │   └── presentation/    # Presentation Layer
│   │
│   └── blog/                # Blog feature
│       ├── data/
│       ├── domain/
│       └── presentation/
│
├── init_dependencies.dart   # DI imports and part directive
├── init_dependencies_main.dart  # GetIt service locator setup
└── main.dart                # App entry point
```

---

## 2. Layer Structure

Each feature follows a three-layer architecture with strict dependency rules.

### 2.1 Domain Layer (Business Logic - Inner Circle)

The domain layer contains the core business logic and is independent of any external frameworks.

#### Entities

Pure Dart classes representing business objects:

```dart
// lib/features/blog/domain/entities/blog.dart
class Blog {
  final String id;
  final String posterId;
  final String title;
  final String content;
  final String imageUrl;
  final List<String> topics;
  final DateTime updatedAt;
  final String? posterName;

  Blog({
    required this.id,
    required this.posterId,
    required this.title,
    required this.content,
    required this.imageUrl,
    required this.topics,
    required this.updatedAt,
    this.posterName,
  });
}
```

#### Repository Contracts

Abstract interfaces defining data operations:

```dart
// lib/features/blog/domain/repositories/blog_repository.dart
abstract interface class BlogRepository {
  Future<Either<Failure, Blog>> uploadBlog({
    required File image,
    required String title,
    required String content,
    required String posterId,
    required List<String> topics,
  });

  Future<Either<Failure, List<Blog>>> getAllBlogs();
  Future<Either<Failure, List<Blog>>> getMyBlogs();
  Future<Either<Failure, Blog>> deleteBlog(String blogId);
  Future<Either<Failure, Blog>> updateBlog({...});
}
```

#### Use Cases

Single-responsibility classes implementing the base UseCase contract:

```dart
// lib/core/usecase/usecase.dart
abstract interface class UseCase<SuccessType, Params> {
  Future<Either<Failure, SuccessType>> call(Params params);
}

class NoParams {}
```

```dart
// lib/features/blog/domain/usecases/upload_blog.dart
class UploadBlog implements UseCase<Blog, UploadBlogParams> {
  final BlogRepository blogRepository;

  UploadBlog(this.blogRepository);

  @override
  Future<Either<Failure, Blog>> call(UploadBlogParams params) async {
    return await blogRepository.uploadBlog(
      image: params.image,
      title: params.title,
      content: params.content,
      posterId: params.posterId,
      topics: params.topics,
    );
  }
}

class UploadBlogParams {
  final String posterId;
  final String title;
  final String content;
  final File image;
  final List<String> topics;

  UploadBlogParams({
    required this.posterId,
    required this.title,
    required this.content,
    required this.image,
    required this.topics,
  });
}
```

### 2.2 Data Layer (Implementation - Outer Circle)

The data layer implements domain contracts and handles data operations.

#### Models

Extend domain entities with serialization capabilities:

```dart
// lib/features/blog/data/models/blog_model.dart
class BlogModel extends Blog {
  BlogModel({
    required super.id,
    required super.posterId,
    required super.title,
    required super.content,
    required super.imageUrl,
    required super.topics,
    required super.updatedAt,
    super.posterName,
  });

  factory BlogModel.fromJson(Map<String, dynamic> map) {
    return BlogModel(
      id: map['id'] as String,
      posterId: map['poster_id'] as String,
      title: map['title'] as String,
      content: map['content'] as String,
      imageUrl: map['image_url'] as String,
      topics: List<String>.from(map['topics'] ?? []),
      updatedAt: map['updated_at'] == null 
          ? DateTime.now() 
          : DateTime.parse(map['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'poster_id': posterId,
      'title': title,
      'content': content,
      'image_url': imageUrl,
      'topics': topics,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  BlogModel copyWith({...}) {
    return BlogModel(...);
  }
}
```

#### Data Sources

Abstract interfaces with implementations for remote (API) and local (cache) data:

```dart
// lib/features/blog/data/datasources/blog_remote_data_source.dart
abstract interface class BlogRemoteDataSource {
  Session? get currentUserSession;
  Future<BlogModel> uploadBlog(BlogModel blog);
  Future<String> uploadBlogImage({required File image, required BlogModel blog});
  Future<List<BlogModel>> getAllBlogs();
  Future<List<BlogModel>> getMyBlogs();
  Future<BlogModel> deleteBlog(String blogId);
  Future<BlogModel> updateBlog(BlogModel blog);
}

class BlogRemoteDataSourceImpl implements BlogRemoteDataSource {
  final SupabaseClient supabaseClient;

  BlogRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<List<BlogModel>> getAllBlogs() async {
    try {
      final blogs = await supabaseClient
          .from('blogs')
          .select('*, profiles (name)');
      return blogs
          .map((blog) => BlogModel.fromJson(blog)
              .copyWith(posterName: blog['profiles']['name']))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
  // ... other implementations
}
```

```dart
// lib/features/blog/data/datasources/blog_local_data_source.dart
abstract interface class BlogLocalDataSource {
  void uploadLocalBlogs({required List<BlogModel> blogs});
  List<BlogModel> loadLocalBlogs();
}

class BlogLocalDataSourceImpl implements BlogLocalDataSource {
  final Box box;

  BlogLocalDataSourceImpl(this.box);

  @override
  List<BlogModel> loadLocalBlogs() {
    List<BlogModel> blogs = [];
    box.read(() {
      for (int i = 0; i < box.length; i++) {
        blogs.add(BlogModel.fromJson(box.get(i.toString())));
      }
    });
    return blogs;
  }

  @override
  void uploadLocalBlogs({required List<BlogModel> blogs}) {
    box.clear();
    box.write(() {
      for (int i = 0; i < blogs.length; i++) {
        box.put(i.toString(), blogs[i].toJson());
      }
    });
  }
}
```

#### Repository Implementation

Implements domain contracts with caching strategy:

```dart
// lib/features/blog/data/repositories/blog_repository_impl.dart
class BlogRepositoryImpl implements BlogRepository {
  final BlogRemoteDataSource blogRemoteDataSource;
  final BlogLocalDataSource blogLocalDataSource;
  final ConnectionChecker connectionChecker;

  BlogRepositoryImpl(
    this.blogRemoteDataSource,
    this.blogLocalDataSource,
    this.connectionChecker,
  );

  @override
  Future<Either<Failure, List<Blog>>> getAllBlogs() async {
    try {
      // Offline-first: Return cached data if no connection
      if (!await connectionChecker.isConnected) {
        final blogs = blogLocalDataSource.loadLocalBlogs();
        return right(blogs);
      }
      // Fetch from remote and cache locally
      final blogs = await blogRemoteDataSource.getAllBlogs();
      blogLocalDataSource.uploadLocalBlogs(blogs: blogs);
      return right(blogs);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
  // ... other implementations
}
```

### 2.3 Presentation Layer (UI)

The presentation layer handles UI and user interactions.

#### Pages

```dart
// lib/features/auth/presentation/pages/login_page.dart
class LoginPage extends StatefulWidget {
  static route() => MaterialPageRoute(
    builder: (context) => const LoginPage(),
  );

  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailureState) {
            showSnackBar(context, state.message);
          } else if (state is AuthSuccessState) {
            Navigator.pushAndRemoveUntil(
              context,
              BlogPage.route(),
              (route) => false,
            );
          }
        },
        builder: (context, state) {
          if (state is AuthLoadingState) {
            return const Loader();
          }
          return Form(
            key: formKey,
            child: Column(
              children: [
                // Form fields...
                AuthGradientButton(
                  buttonText: 'Sign In',
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      context.read<AuthBloc>().add(AuthLoginEvent(
                        email: emailController.text.trim(),
                        password: passwordController.text.trim(),
                      ));
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
```

---

## 3. State Management

This project uses **BLoC** for complex features and **Cubit** for simpler state management.

### 3.1 BLoC Pattern (Events → BLoC → States)

#### Events

```dart
// lib/features/auth/presentation/blocs/auth_event.dart
part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

final class AuthSignUpEvent extends AuthEvent {
  final String email;
  final String password;
  final String name;

  AuthSignUpEvent({
    required this.email,
    required this.password,
    required this.name,
  });
}

final class AuthLoginEvent extends AuthEvent {
  final String email;
  final String password;

  AuthLoginEvent({
    required this.email,
    required this.password,
  });
}

final class AuthIsUserLoggedInEvent extends AuthEvent {}

final class AuthLogoutEvent extends AuthEvent {}
```

#### States

```dart
// lib/features/auth/presentation/blocs/auth_state.dart
part of 'auth_bloc.dart';

@immutable
sealed class AuthState {
  const AuthState();
}

final class AuthInitialState extends AuthState {}

final class AuthLoadingState extends AuthState {}

final class AuthFailureState extends AuthState {
  final String message;
  const AuthFailureState(this.message);
}

final class AuthSuccessState extends AuthState {
  final User user;
  const AuthSuccessState(this.user);
}

final class AuthLogoutSuccessState extends AuthState {}
```

#### BLoC

```dart
// lib/features/auth/presentation/blocs/auth_bloc.dart
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserSignUp _userSignUp;
  final UserLogin _userLogin;
  final CurrentUser _currentUser;
  final AppUserCubit _appUserCubit;
  final UserSignOut _userSignOut;

  AuthBloc({
    required UserSignUp userSignUp,
    required UserLogin userLogin,
    required CurrentUser currentUser,
    required AppUserCubit appUserCubit,
    required UserSignOut userSignOut,
  })  : _userSignUp = userSignUp,
        _userLogin = userLogin,
        _currentUser = currentUser,
        _appUserCubit = appUserCubit,
        _userSignOut = userSignOut,
        super(AuthInitialState()) {
    on<AuthEvent>((_, emit) => emit(AuthLoadingState()));
    on<AuthSignUpEvent>(_onAuthSignUp);
    on<AuthLoginEvent>(_onAuthLogin);
    on<AuthIsUserLoggedInEvent>(_onAuthIsUserLoggedIn);
    on<AuthLogoutEvent>(_onAuthLogout);
  }

  void _onAuthLogin(AuthLoginEvent event, Emitter<AuthState> emit) async {
    final response = await _userLogin(
      UserLoginParams(
        email: event.email,
        password: event.password,
      ),
    );
    response.fold(
      (failure) => emit(AuthFailureState(failure.message)),
      (user) => _emitAuthSuccess(user, emit),
    );
  }

  void _emitAuthSuccess(User user, Emitter<AuthState> emit) {
    _appUserCubit.updateUser(user);
    emit(AuthSuccessState(user));
  }
  // ... other handlers
}
```

### 3.2 Cubit Pattern (For Simpler State)

```dart
// lib/core/common/cubits/app_user/app_user_cubit.dart
class AppUserCubit extends Cubit<AppUserState> {
  AppUserCubit() : super(AppUserInitialState());

  void updateUser(User? user) {
    if (user == null) {
      emit(AppUserInitialState());
    } else {
      emit(AppUserLoggedInState(user));
    }
  }
}
```

```dart
// lib/core/common/cubits/app_user/app_user_state.dart
part of 'app_user_cubit.dart';

@immutable
sealed class AppUserState {}

final class AppUserInitialState extends AppUserState {}

final class AppUserLoggedInState extends AppUserState {
  final User user;
  AppUserLoggedInState(this.user);
}
```

### 3.3 Providing BLoCs/Cubits

```dart
// lib/main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => serviceLocator<AppUserCubit>()),
        BlocProvider(create: (_) => serviceLocator<AuthBloc>()),
        BlocProvider(create: (_) => serviceLocator<BlogBloc>()),
      ],
      child: const MyApp(),
    ),
  );
}
```

---

## 4. Dependency Injection

Using **GetIt** as the service locator for dependency injection.

### 4.1 Service Locator Setup

```dart
// lib/init_dependencies_main.dart
part of 'init_dependencies.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  _initAuth();
  _initBlog();
  
  // Initialize Supabase
  final supabase = await Supabase.initialize(
    url: AppSecrets.supabaseUrl,
    anonKey: AppSecrets.supabaseAnonKey,
  );

  // Initialize Hive for local storage
  Hive.defaultDirectory = (await getApplicationDocumentsDirectory()).path;

  // Register core dependencies
  serviceLocator.registerLazySingleton(() => Hive.box(name: 'blogs'));
  serviceLocator.registerLazySingleton(() => supabase.client);
  serviceLocator.registerFactory(() => InternetConnection());
  serviceLocator.registerLazySingleton(() => AppUserCubit());
  serviceLocator.registerFactory<ConnectionChecker>(
    () => ConnectionCheckerImpl(serviceLocator()),
  );
}
```

### 4.2 Feature-Based DI Initialization

```dart
void _initAuth() {
  serviceLocator
    // Data Source
    ..registerFactory<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(serviceLocator()),
    )
    // Repository
    ..registerFactory<AuthRepository>(
      () => AuthRepositoryImpl(serviceLocator(), serviceLocator()),
    )
    // Use Cases
    ..registerFactory(() => UserSignUp(serviceLocator()))
    ..registerFactory(() => UserLogin(serviceLocator()))
    ..registerFactory(() => CurrentUser(serviceLocator()))
    ..registerFactory(() => UserSignOut(serviceLocator()))
    // BLoC (Lazy Singleton - single instance)
    ..registerLazySingleton(
      () => AuthBloc(
        userSignUp: serviceLocator(),
        userLogin: serviceLocator(),
        currentUser: serviceLocator(),
        appUserCubit: serviceLocator(),
        userSignOut: serviceLocator(),
      ),
    );
}

void _initBlog() {
  serviceLocator
    // Data Sources
    ..registerFactory<BlogRemoteDataSource>(
      () => BlogRemoteDataSourceImpl(serviceLocator()),
    )
    ..registerFactory<BlogLocalDataSource>(
      () => BlogLocalDataSourceImpl(serviceLocator()),
    )
    // Repository
    ..registerFactory<BlogRepository>(
      () => BlogRepositoryImpl(
        serviceLocator(),
        serviceLocator(),
        serviceLocator(),
      ),
    )
    // Use Cases
    ..registerFactory(() => UploadBlog(serviceLocator()))
    ..registerFactory(() => GetAllBlogs(serviceLocator()))
    ..registerFactory(() => GetMyBlogs(serviceLocator()))
    ..registerFactory(() => DeleteBlog(serviceLocator()))
    ..registerFactory(() => UpdateBlog(serviceLocator()))
    // BLoC
    ..registerLazySingleton(
      () => BlogBloc(
        uploadBlog: serviceLocator(),
        getAllBlogs: serviceLocator(),
        getMyBlogs: serviceLocator(),
        deleteBlog: serviceLocator(),
        updateBlog: serviceLocator(),
      ),
    );
}
```

---

## 5. Error Handling

Using functional programming with **fpdart** for type-safe error handling.

### 5.1 Failure Class

```dart
// lib/core/error/failure.dart
class Failure {
  final String message;
  Failure([this.message = 'An unexpected error occurred.']);
}
```

### 5.2 Exception Class

```dart
// lib/core/error/exception.dart
class ServerException implements Exception {
  final String message;
  ServerException(this.message);
}
```

### 5.3 Error Flow

```
DataSource (throws ServerException)
    ↓
Repository (catches & returns Left(Failure))
    ↓
UseCase (passes through Either)
    ↓
BLoC (handles with .fold())
    ↓
UI (shows error message)
```

### 5.4 Usage in Repository

```dart
Future<Either<Failure, List<Blog>>> getAllBlogs() async {
  try {
    if (!await connectionChecker.isConnected) {
      return left(Failure(Constants.noConnectionErrorMessage));
    }
    final blogs = await blogRemoteDataSource.getAllBlogs();
    return right(blogs);
  } on ServerException catch (e) {
    return left(Failure(e.message));
  }
}
```

### 5.5 Usage in BLoC

```dart
void _onAuthLogin(AuthLoginEvent event, Emitter<AuthState> emit) async {
  final response = await _userLogin(
    UserLoginParams(email: event.email, password: event.password),
  );
  response.fold(
    (failure) => emit(AuthFailureState(failure.message)),
    (user) => _emitAuthSuccess(user, emit),
  );
}
```

---

## 6. Key Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_bloc` | latest | State management (BLoC + Cubit) |
| `get_it` | latest | Dependency injection |
| `fpdart` | latest | Functional programming (`Either`, `Option`) |
| `supabase_flutter` | latest | Backend (Auth, Database, Storage) |
| `hive` | ^4.0.0-dev.2 | Local caching/offline storage |
| `internet_connection_checker_plus` | latest | Network connectivity checking |
| `uuid` | latest | Unique ID generation |
| `intl` | latest | Date formatting & internationalization |
| `image_picker` | latest | Image selection from gallery/camera |
| `path_provider` | latest | File system paths |
| `dotted_border` | latest | UI component for dotted borders |

---

## 7. Design Principles

### 7.1 Dependency Rule

- Inner layers (domain) **cannot** depend on outer layers (data/presentation)
- Outer layers **can** depend on inner layers
- Core module **cannot** depend on feature modules
- Feature modules **can** depend on core

### 7.2 Interface Segregation

All repositories and data sources are defined as abstract interfaces:

```dart
abstract interface class BlogRepository { ... }
abstract interface class BlogRemoteDataSource { ... }
abstract interface class BlogLocalDataSource { ... }
abstract interface class ConnectionChecker { ... }
```

### 7.3 Single Responsibility

Each use case handles exactly one operation:

- `UploadBlog` - uploads a single blog
- `GetAllBlogs` - fetches all blogs
- `DeleteBlog` - deletes a single blog

### 7.4 Offline-First Strategy

Repository checks connectivity and falls back to cached data:

```dart
if (!await connectionChecker.isConnected) {
  final blogs = blogLocalDataSource.loadLocalBlogs();
  return right(blogs);
}
final blogs = await blogRemoteDataSource.getAllBlogs();
blogLocalDataSource.uploadLocalBlogs(blogs: blogs);
return right(blogs);
```

### 7.5 Testability

- All dependencies are injected via constructor
- Abstract interfaces allow easy mocking
- Use cases are isolated and independently testable

---

## 8. Naming Conventions

### 8.1 Files

| Type | Convention | Example |
|------|------------|---------|
| Entity | `singular.dart` | `blog.dart`, `user.dart` |
| Model | `singular_model.dart` | `blog_model.dart`, `user_model.dart` |
| Repository (abstract) | `feature_repository.dart` | `blog_repository.dart` |
| Repository (impl) | `feature_repository_impl.dart` | `blog_repository_impl.dart` |
| Remote Data Source | `feature_remote_data_source.dart` | `blog_remote_data_source.dart` |
| Local Data Source | `feature_local_data_source.dart` | `blog_local_data_source.dart` |
| Use Case | `verb_noun.dart` | `upload_blog.dart`, `get_all_blogs.dart` |
| BLoC | `feature_bloc.dart` | `auth_bloc.dart`, `blog_bloc.dart` |
| BLoC Events | `feature_event.dart` | `auth_event.dart` |
| BLoC States | `feature_state.dart` | `auth_state.dart` |
| Cubit | `feature_cubit.dart` | `app_user_cubit.dart` |
| Cubit States | `feature_state.dart` | `app_user_state.dart` |
| Page | `feature_page.dart` | `login_page.dart`, `blog_page.dart` |
| Widget | `feature_widget.dart` | `auth_field.dart`, `blog_card.dart` |

### 8.2 Classes

| Type | Convention | Example |
|------|------------|---------|
| Entity | `PascalCase` | `Blog`, `User` |
| Model | `EntityModel` | `BlogModel`, `UserModel` |
| Repository (abstract) | `FeatureRepository` | `BlogRepository` |
| Repository (impl) | `FeatureRepositoryImpl` | `BlogRepositoryImpl` |
| Data Source (abstract) | `FeatureRemoteDataSource` | `BlogRemoteDataSource` |
| Data Source (impl) | `FeatureRemoteDataSourceImpl` | `BlogRemoteDataSourceImpl` |
| Use Case | `VerbNoun` | `UploadBlog`, `GetAllBlogs` |
| Use Case Params | `UseCaseParams` | `UploadBlogParams` |
| BLoC | `FeatureBloc` | `AuthBloc`, `BlogBloc` |
| Event (base) | `FeatureEvent` | `AuthEvent` |
| Event (specific) | `FeatureActionEvent` | `AuthLoginEvent` |
| State (base) | `FeatureState` | `AuthState` |
| State (specific) | `FeatureStatusState` | `AuthLoadingState` |

### 8.3 BLoC Event/State Naming

```dart
// Events: Feature + Action + Event
AuthSignUpEvent
AuthLoginEvent
AuthLogoutEvent
BlogUploadEvent
BlogDeleteEvent

// States: Feature + Status + State
AuthInitialState
AuthLoadingState
AuthSuccessState
AuthFailureState
BlogLoadedState
BlogEmptyState
```

---

## 9. New Feature Template

When adding a new feature, create the following structure:

```
lib/features/NEW_FEATURE/
├── data/
│   ├── datasources/
│   │   ├── new_feature_local_data_source.dart
│   │   └── new_feature_remote_data_source.dart
│   ├── models/
│   │   └── new_feature_model.dart
│   └── repositories/
│       └── new_feature_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── new_feature.dart
│   ├── repositories/
│   │   └── new_feature_repository.dart
│   └── usecases/
│       ├── create_new_feature.dart
│       ├── get_new_feature.dart
│       ├── get_all_new_features.dart
│       ├── update_new_feature.dart
│       └── delete_new_feature.dart
└── presentation/
    ├── blocs/
    │   ├── new_feature_bloc.dart
    │   ├── new_feature_event.dart
    │   └── new_feature_state.dart
    ├── pages/
    │   ├── new_feature_page.dart
    │   └── new_feature_detail_page.dart
    └── widgets/
        ├── new_feature_card.dart
        └── new_feature_form.dart
```

### 9.1 Step-by-Step Guide

1. **Create Entity** (domain/entities/)
2. **Create Repository Contract** (domain/repositories/)
3. **Create Use Cases** (domain/usecases/)
4. **Create Model** extending Entity (data/models/)
5. **Create Data Source Interfaces & Implementations** (data/datasources/)
6. **Create Repository Implementation** (data/repositories/)
7. **Create BLoC Events & States** (presentation/blocs/)
8. **Create BLoC** (presentation/blocs/)
9. **Register Dependencies** in `init_dependencies_main.dart`
10. **Create UI Pages & Widgets** (presentation/pages/, presentation/widgets/)
11. **Add BlocProvider** in `main.dart`

---

## Summary

This architecture provides:

- ✅ **Scalability** - Easy to add new features
- ✅ **Testability** - All layers can be tested independently
- ✅ **Maintainability** - Clear separation of concerns
- ✅ **Offline Support** - Built-in caching strategy
- ✅ **Type Safety** - Functional error handling with Either
- ✅ **Flexibility** - Easy to swap implementations (e.g., change backend)

---

*Generated for Blog Bloom Flutter Project*

