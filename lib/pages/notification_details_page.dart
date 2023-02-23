import 'package:flutter/material.dart';

class NotificationDetailsPage extends StatelessWidget {
  final String? title;
  final String? subTitle;
  final String? imgUrl;
  const NotificationDetailsPage({
    Key? key,
    required this.title,
    required this.subTitle,
    required this.imgUrl,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        titleTextStyle: TextStyle(
            color: Colors.black45, fontWeight: FontWeight.w600, fontSize: 19),
        centerTitle: true,
        elevation: 0,
        title: Text('Notification Details'),
        leading: IconButton(
          color: Colors.black54,
          onPressed: () =>
              Navigator.of(context).popUntil((route) => route.isFirst),
          icon: Icon(Icons.arrow_back_ios),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title ?? 'N/A',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 20),
            imgUrl != null
                ? Image.network(
                    imgUrl!,
                    loadingBuilder: (context, child, progress) {
                      return progress == null
                          ? child
                          : CircularProgressIndicator(
                              value: progress.expectedTotalBytes != null
                                  ? progress.cumulativeBytesLoaded /
                                      progress.expectedTotalBytes!
                                  : null,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.blueAccent),
                            );
                    },
                    errorBuilder: (context, error, stackTrace) =>
                        Text('Fetch image error'),
                  )
                : SizedBox.shrink(),
            SizedBox(height: imgUrl != null ? 20 : 0),
            Text(
              subTitle ?? 'N/A',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
