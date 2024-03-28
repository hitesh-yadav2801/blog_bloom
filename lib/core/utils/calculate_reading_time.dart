int calculateReadingTime(String content) {
  final wordCount = content.split(RegExp(r'\s+')).length;
  // speed = distance / time
  final readingTime = wordCount / 200;
  return readingTime.ceil();
}