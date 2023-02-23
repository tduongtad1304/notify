class Notifications {
  final String? title;
  final String? body;
  final String? imgUrl;
  final String? dataTitle;
  final String? dataBody;
  Notifications({
    this.title,
    this.body,
    this.imgUrl,
    this.dataTitle,
    this.dataBody,
  });

  @override
  String toString() {
    return 'Notification(title: $title, body: $body, dataTitle: $dataTitle, dataBody: $dataBody)';
  }
}
