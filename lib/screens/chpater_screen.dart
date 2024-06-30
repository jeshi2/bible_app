import 'package:flutter/material.dart';
import 'package:bible_app/models/book.dart';
import 'dart:ui';

class ChapterScreen extends StatelessWidget {
  final Book book;
  final int chapterIndex;
  final int? highlightedVerseIndex;
  final String? highlightedText;

  const ChapterScreen({
    Key? key,
    required this.book,
    required this.chapterIndex,
    this.highlightedVerseIndex,
    this.highlightedText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text('${book.name} - Chapter ${chapterIndex + 1}'),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: book.chapters[chapterIndex].length,
          itemBuilder: (context, verseIndex) {
            final verse = book.chapters[chapterIndex][verseIndex];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${verseIndex + 1} ',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                        fontFeatures: [FontFeature.superscripts()],
                      ),
                    ),
                    TextSpan(
                      text: verse,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        backgroundColor: highlightedVerseIndex == verseIndex &&
                                highlightedText != null &&
                                verse
                                    .toLowerCase()
                                    .contains(highlightedText!.toLowerCase())
                            ? Colors.yellow
                            : Colors.transparent,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
