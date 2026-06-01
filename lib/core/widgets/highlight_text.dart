import 'package:flutter/material.dart';

class HighlightText extends StatelessWidget {
  final String text;
  final String query;

  const HighlightText({
    super.key,
    required this.text,
    required this.query,
  });

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) {
      return Text(text);
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();

    List<TextSpan> spans = [];
    int start = 0;

    while (true) {
      final index =
          lowerText.indexOf(lowerQuery, start);

      if (index == -1) {
        spans.add(TextSpan(
          text: text.substring(start),
        ));
        break;
      }

      if (index > start) {
        spans.add(TextSpan(
          text: text.substring(start, index),
        ));
      }

      spans.add(TextSpan(
        text: text.substring(
          index,
          index + query.length,
        ),
        style: const TextStyle(
          backgroundColor:
              Color(0xFFFFF59D),
          fontWeight: FontWeight.bold,
        ),
      ));

      start = index + query.length;
    }

    return RichText(
      text: TextSpan(
        style: const TextStyle(
          color: Colors.black,
          fontSize: 14,
        ),
        children: spans,
      ),
    );
  }
}