import 'package:flutter/material.dart';

Widget buildMessageText(String text, bool isUser) {
  List<Widget> children = [];

  List<String> lines = text.split('\n');

  for (String line in lines) {
    bool isBullet = line.trim().startsWith('* ');

    String content = isBullet ? line.trim().substring(2) : line;

    List<InlineSpan> spans = [];
    RegExp exp = RegExp(r'\*\*([^*]+)\*\*');
    Iterable<RegExpMatch> matches = exp.allMatches(content);

    int currentIndex = 0;

    for (final match in matches) {
      if (match.start > currentIndex) {
        spans.add(TextSpan(
          text: content.substring(currentIndex, match.start),
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black,
            height: 2,
          ),
        ));
      }

      spans.add(TextSpan(
        text: match.group(1),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isUser ? Colors.white : Colors.black,
          height: 2,
        ),
      ));

      currentIndex = match.end;
    }

    if (currentIndex < content.length) {
      spans.add(TextSpan(
        text: content.substring(currentIndex),
        style: TextStyle(
          color: isUser ? Colors.white : Colors.black,
          height: 2,
        ),
      ));
    }

    if (isBullet) {
      children.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '• ',
              style: TextStyle(
                color: isUser ? Colors.white : Colors.black,
                height: 2,
              ),
            ),
            Expanded(
              child: RichText(
                text: TextSpan(children: spans),
              ),
            ),
          ],
        ),
      );
    } else {
      children.add(
        RichText(
          text: TextSpan(children: spans),
        ),
      );
    }

    children.add(SizedBox(height: 4)); // spacing between lines
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: children,
  );
}
