import 'package:blog_bloom/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:blog_bloom/core/common/widgets/loader.dart';
import 'package:blog_bloom/core/utils/random_color_generator.dart';
import 'package:blog_bloom/core/utils/show_snackbar.dart';
import 'package:blog_bloom/features/blog/domain/entities/blog.dart';
import 'package:blog_bloom/features/blog/presentation/blocs/blog_bloc.dart';
import 'package:blog_bloom/features/blog/presentation/pages/add_new_blog_page.dart';
import 'package:blog_bloom/features/blog/presentation/pages/blog_viewer_page.dart';
import 'package:blog_bloom/features/blog/presentation/widgets/app_drawer.dart';
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
  String selectedChip = 'All Blogs';
  List<Blog> myBlogs = [];

  @override
  void initState() {
    super.initState();
    print('here');
    context.read<BlogBloc>().add(BlogFetchAllBlogsEvent());
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId =
        (context.read<AppUserCubit>().state as AppUserLoggedInState).user.id;
    return Scaffold(
      drawer: const AppDrawer(),
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
        ],
      ),
      body: Column(
        children: [
          Row(
            children: [
              FilterChip(
                label: const Text('All Blogs'),
                selected: selectedChip == 'All Blogs',
                onSelected: (isSelected) {
                  if (isSelected) {
                    setState(() {
                      selectedChip = 'All Blogs';
                    });
                    context.read<BlogBloc>().add(BlogFetchAllBlogsEvent());
                  }
                },
              ),
              const SizedBox(width: 10),
              FilterChip(
                label: const Text('My Blogs'),
                selected: selectedChip == 'My Blogs',
                onSelected: (isSelected) {
                  if (isSelected) {
                    setState(() {
                      selectedChip = 'My Blogs';
                    });
                    context
                        .read<BlogBloc>()
                        .add(BlogFetchMyBlogsEvent(myBlogs));
                  }
                },
              ),
            ],
          ),
          BlocConsumer<BlogBloc, BlogState>(
            listener: (context, state) {
              if (state is BlogFailureState) {
                showSnackBar(context, state.error);
              }
            },
            builder: (context, state) {
              if (state is BlogLoadingState) {
                return const Loader();
              }
              if (state is BlogMyDisplaySuccessState) {
                return Expanded(
                  child: ListView.builder(
                    itemCount: state.blogs.length,
                    itemBuilder: (context, index) {
                      final blog = state.blogs[index];
                      return BlogCard(
                        blog: blog,
                        color: getRandomColor(),
                        onTap: () {
                          Navigator.push(
                              context, BlogViewerPage.route(blog, true));
                        },
                      );
                    },
                  ),
                );
              }
              if (state is BlogDisplaySuccessState) {
                myBlogs = state.blogs
                    .where((blog) => blog.posterId == currentUserId)
                    .toList();
                return Expanded(
                  child: ListView.builder(
                    itemCount: state.blogs.length,
                    itemBuilder: (context, index) {
                      final blog = state.blogs[index];
                      return BlogCard(
                        blog: blog,
                        color: getRandomColor(),
                        onTap: () {
                          Navigator.push(
                              context, BlogViewerPage.route(blog, false));
                        },
                      );
                    },
                  ),
                );
              }
              return const SizedBox();
            },
          ),
        ],
      ),
    );
  }
}
