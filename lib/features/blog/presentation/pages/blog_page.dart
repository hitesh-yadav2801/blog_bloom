import 'package:blog_bloom/core/common/widgets/loader.dart';
import 'package:blog_bloom/core/theme/app_palette.dart';
import 'package:blog_bloom/core/utils/show_snackbar.dart';
import 'package:blog_bloom/features/blog/domain/entities/blog.dart';
import 'package:blog_bloom/features/blog/domain/entities/blog.dart';
import 'package:blog_bloom/features/blog/presentation/blocs/blog_bloc.dart';
import 'package:blog_bloom/features/blog/presentation/pages/add_new_blog.dart';
import 'package:blog_bloom/features/blog/presentation/widgets/blog_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BlogPage extends StatefulWidget {
  static route() =>
      MaterialPageRoute(
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
          )
        ],
      ),
      body: BlocConsumer<BlogBloc, BlogState>(
        listener: (context, state) {
          if(state is BlogFailureState) {
            showSnackBar(context, state.error);
          }
        },
        builder: (context, state) {
          if(state is BlogLoadingState) {
            return const Loader();
          }
          if(state is BlogDisplaySuccessState) {
            return ListView.builder(
              itemCount: state.blogs.length,
              itemBuilder: (context, index){
                final blog = state.blogs[index];
                return BlogCard(blog: blog, color: AppPalette.gradient1,);
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
