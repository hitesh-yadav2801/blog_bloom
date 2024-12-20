part of 'blog_bloc.dart';

@immutable
sealed class BlogState {}

final class BlogInitialState extends BlogState {}

final class BlogLoadingState extends BlogState {}

final class BlogFailureState extends BlogState {
  final String error;

  BlogFailureState(this.error);
}

final class BlogUploadSuccessState extends BlogState {}

final class BlogDisplaySuccessState extends BlogState {
  final List<Blog> blogs;

  BlogDisplaySuccessState(this.blogs);
}

final class BlogMyDisplaySuccessState extends BlogState {
  final List<Blog> blogs;

  BlogMyDisplaySuccessState(this.blogs);
}

final class BlogDeleteSuccessState extends BlogState {
  final Blog blog;

  BlogDeleteSuccessState(this.blog);
}

final class BlogUpdateSuccessState extends BlogState {
  final Blog blog;

  BlogUpdateSuccessState(this.blog);
}
