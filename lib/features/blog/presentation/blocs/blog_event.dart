part of 'blog_bloc.dart';

@immutable
sealed class BlogEvent {}

final class BlogUploadEvent extends BlogEvent {
  final String posterId;
  final String title;
  final String content;
  final File image;
  final List<String> topics;

  BlogUploadEvent({
    required this.posterId,
    required this.title,
    required this.content,
    required this.image,
    required this.topics,
  });
}

final class BlogFetchAllBlogsEvent extends BlogEvent {}

final class BlogFetchMyBlogsEvent extends BlogEvent {
  final List<Blog>? blogs;

  BlogFetchMyBlogsEvent(this.blogs);
}

final class BlogDeleteEvent extends BlogEvent {
  final String blogId;

  BlogDeleteEvent({required this.blogId});
}

final class BlogUpdateEvent extends BlogEvent {
  final String posterId;
  final String blogId;
  final String title;
  final String content;
  final List<String> topics;
  final File image;

  BlogUpdateEvent({
    required this.posterId,
    required this.blogId,
    required this.title,
    required this.content,
    required this.topics,
    required this.image,
  });
}
