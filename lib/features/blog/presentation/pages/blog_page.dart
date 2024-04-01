import 'package:blog_bloom/core/common/widgets/loader.dart';
import 'package:blog_bloom/core/utils/random_color_generator.dart';
import 'package:blog_bloom/core/utils/show_alert_dialog.dart';
import 'package:blog_bloom/core/utils/show_snackbar.dart';
import 'package:blog_bloom/features/auth/presentation/blocs/auth_bloc.dart';
import 'package:blog_bloom/features/auth/presentation/pages/login_page.dart';
import 'package:blog_bloom/features/blog/presentation/blocs/blog_bloc.dart';
import 'package:blog_bloom/features/blog/presentation/pages/add_new_blog_page.dart';
import 'package:blog_bloom/features/blog/presentation/widgets/blog_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BlogPage extends StatefulWidget {
  static route() => MaterialPageRoute(
        builder: (context) => const BlogPage(),
      );

  const BlogPage({super.key});

  @override
  State<BlogPage> createState() => _BlogPageState();
}

class _BlogPageState extends State<BlogPage> {
  @override
  void initState() {
    super.initState();
    context.read<BlogBloc>().add(BlogFetchAllBlogsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blog Bloom'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                AddNewBlogPage.route(),
              );
            },
            icon: const Icon(
              CupertinoIcons.add_circled,
            ),
          ),
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return BlocConsumer<AuthBloc, AuthState>(
                    listener: (context, state) {
                      if (state is AuthFailureState) {
                        showSnackBar(context, state.message);
                        Navigator.pop(context);
                      } else if (state is AuthLogoutSuccessState) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          LoginPage.route(),
                          (route) => false,
                        );
                      }
                    },
                    builder: (context, state) {
                      if (state is AuthLoadingState) {
                        return const Loader();
                      }
                      return CustomAlertDialog(
                        onConfirm: () {
                          context.read<AuthBloc>().add(AuthLogoutEvent());
                        },
                      );
                    },
                  );
                },
              );
            },
            icon: const Icon(Icons.logout_rounded),
          )
        ],
      ),
      body: BlocConsumer<BlogBloc, BlogState>(
        listener: (context, state) {
          if (state is BlogFailureState) {
            showSnackBar(context, state.error);
          }
        },
        builder: (context, state) {
          if (state is BlogLoadingState) {
            return const Loader();
          }
          if (state is BlogDisplaySuccessState) {
            return ListView.builder(
              itemCount: state.blogs.length,
              itemBuilder: (context, index) {
                final blog = state.blogs[index];
                return BlogCard(
                  blog: blog,
                  color: getRandomColor(),
                );
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
