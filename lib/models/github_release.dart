class GitHubRelease {
  final String name;
  final String body;
  final String htmlUrl;

  GitHubRelease({
    required this.name,
    required this.body,
    required this.htmlUrl,
  });

  factory GitHubRelease.fromJson(Map<String, dynamic> json) {
    return GitHubRelease(
      name: json['name'],
      body: json['body'],
      htmlUrl: json['html_url'],
    );
  }
}
