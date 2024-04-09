import 'package:blog_bloom/core/common/widgets/loader.dart';
import 'package:blog_bloom/core/theme/app_palette.dart';
import 'package:blog_bloom/core/utils/calculate_reading_time.dart';
import 'package:blog_bloom/core/utils/format_date.dart';
import 'package:blog_bloom/core/utils/show_alert_dialog.dart';
import 'package:blog_bloom/core/utils/show_snackbar.dart';
import 'package:blog_bloom/features/blog/domain/entities/blog.dart';
import 'package:blog_bloom/features/blog/presentation/blocs/blog_bloc.dart';
import 'package:blog_bloom/features/blog/presentation/pages/blog_page.dart';
import 'package:blog_bloom/features/blog/presentation/pages/update_blog_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BlogViewerPage extends StatelessWidget {
  static route(Blog blog, bool? isEditingPage) => MaterialPageRoute(
        builder: (context) =>
            BlogViewerPage(blog: blog, isEditingPage: isEditingPage),
      );

  final Blog blog;
  final bool? isEditingPage;

  const BlogViewerPage({super.key, required this.blog, this.isEditingPage});

  @override
  Widget build(BuildContext context) {
    print(blog.id);
    return BlocConsumer<BlogBloc, BlogState>(
      listener: (context, state) {
        if (state is BlogFailureState) {
          showSnackBar(context, state.error);
        } else if (state is BlogDeleteSuccessState) {
          Navigator.pushAndRemoveUntil(
            context,
            BlogPage.route(),
            (route) => false,
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            actions: [
              if (isEditingPage ?? false)
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      UpdateBlogPage.route(blog),
                    );
                  },
                  icon: const Icon(
                    Icons.edit,
                  ),
                ),
              if (isEditingPage ?? false)
                IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return BlocBuilder<BlogBloc, BlogState>(
                          builder: (context, state) {
                            if (state is BlogLoadingState) {
                              return const Loader();
                            }
                            return CustomAlertDialog(
                              title: 'Delete Blog',
                              content: 'Are you sure you want to delete this blog?',
                              confirmText: 'Delete',
                              cancelText: 'Cancel',
                              onConfirm: () {
                                context
                                    .read<BlogBloc>()
                                    .add(BlogDeleteEvent(blogId: blog.id));
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                  icon: const Icon(
                    Icons.delete,
                  ),
                ),

            ],
          ),
          body: Scrollbar(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      blog.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'By ${blog.posterName}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${formatDateBydMMMYYYY(blog.updatedAt)} • ${calculateReadingTime(blog.content)} min read',
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppPalette.greyColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        blog.imageUrl,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      blog.content,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
