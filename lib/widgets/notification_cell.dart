import 'package:flutter/material.dart';

class NotificationCell extends StatelessWidget {
  final void Function()? onTap;
  final bool isHasImage;
  final String? title;
  final String? body;
  const NotificationCell({
    Key? key,
    this.onTap,
    this.title,
    this.body,
    required this.isHasImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return (title != null && body != null)
        ? GestureDetector(
            onTap: onTap,
            child: Center(
              child: Stack(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    width: 300,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black54,
                          offset: Offset(2, 2),
                          blurRadius: 2.5,
                          blurStyle: BlurStyle.normal,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          title!,
                          textAlign: TextAlign.justify,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          body!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 16.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  isHasImage
                      ? Positioned(
                          child: Icon(Icons.image, color: Colors.redAccent),
                          left: 270,
                          top: 40)
                      : const SizedBox.shrink(),
                ],
              ),
            ),
          )
        : const SizedBox.shrink();
  }
}
