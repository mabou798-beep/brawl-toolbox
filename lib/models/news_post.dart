class NewsPost {
  final String title;
  final String summary;
  final String body;
  final String category;
  final String author;
  final String timeAgo;
  final int upvotes;
  final int comments;

  const NewsPost({
    required this.title,
    required this.summary,
    required this.body,
    required this.category,
    required this.author,
    required this.timeAgo,
    required this.upvotes,
    required this.comments,
  });
}
