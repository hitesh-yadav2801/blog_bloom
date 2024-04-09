import 'package:blog_bloom/core/common/widgets/loader.dart';
import 'package:blog_bloom/core/utils/random_color_generator.dart';
import 'package:blog_bloom/core/utils/show_snackbar.dart';
import 'package:blog_bloom/features/blog/presentation/blocs/blog_bloc.dart';
import 'package:blog_bloom/features/blog/presentation/widgets/blog_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyBlogsPage extends StatefulWidget {
  static route() => MaterialPageRoute(
        builder: (context) => const MyBlogsPage(),
      );

  const MyBlogsPage({super.key});

  @override
  State<MyBlogsPage> createState() => _MyBlogsPageState();
}

class _MyBlogsPageState extends State<MyBlogsPage> {
  @override
  void initState() {
    super.initState();
    //context.read<BlogBloc>().add(BlogFetchMyBlogsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Blogs'),
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
          if (state is BlogMyDisplaySuccessState) {
            return ListView.builder(
              itemCount: state.blogs.length,
              itemBuilder: (context, index) {
                final blog = state.blogs[index];
                return BlogCard(
                  blog: blog,
                  color: getRandomColor(),
                  onTap: () {},
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
