import 'package:blog_bloom/features/blog/data/models/blog_model.dart';
import 'package:hive/hive.dart';

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
      for(int i = 0; i < box.length; i++){
        blogs.add(BlogModel.fromJson(box.get(i.toString())));
      }
    });
    print("Im here");
    return blogs;
  }

  @override
  void uploadLocalBlogs({required List<BlogModel> blogs}) {
    print("I'm here");
    box.clear();
    box.write(() {
      for(int i = 0; i < blogs.length; i++){
        box.put(i.toString(), blogs[i].toJson());
      }
    });
  }
}