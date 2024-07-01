// ignore_for_file: avoid_print

import 'package:bible_app/utils/bookmark_provider.dart';
import 'package:flutter/material.dart';
import 'package:bible_app/models/book.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:ui';
import 'package:provider/provider.dart';

class ChapterScreen extends StatefulWidget {
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
  // ignore: library_private_types_in_public_api
  _ChapterScreenState createState() => _ChapterScreenState();
}

class _ChapterScreenState extends State<ChapterScreen> {
  FlutterTts flutterTts = FlutterTts();
  bool isPlaying = false;
  int? currentPlayingVerseIndex;
  double pitch = 1.0;
  double speed = 1.0;

  @override
  void initState() {
    super.initState();
    initTts();
  }

  Future<void> initTts() async {
    try {
      await flutterTts.setLanguage("en-US");
      await flutterTts.setPitch(pitch);
      await flutterTts.setSpeechRate(speed);
      flutterTts.setStartHandler(() {
        setState(() {
          isPlaying = true;
        });
      });
      flutterTts.setCompletionHandler(() {
        setState(() {
          isPlaying = false;
          currentPlayingVerseIndex = null;
        });
      });
      flutterTts.setErrorHandler((msg) {
        setState(() {
          isPlaying = false;
          currentPlayingVerseIndex = null;
        });
        print("Error: $msg");
      });
    } catch (e) {
      print("Error initializing TTS: $e");
    }
  }

  Future<void> speakVerse(String text, int verseIndex) async {
    await flutterTts.setPitch(pitch);
    await flutterTts.setSpeechRate(speed);
    await flutterTts.speak(text);
    setState(() {
      currentPlayingVerseIndex = verseIndex;
    });
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                '${widget.book.name} - Chapter ${widget.chapterIndex + 1}',
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.red,
                  ),
                  onPressed: () {
                    setState(() {
                      if (isPlaying) {
                        flutterTts.stop();
                      } else {
                        speakChapter();
                      }
                      isPlaying = !isPlaying;
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.volume_up),
                  onPressed: () {
                    showSpeedPitchDialog();
                  },
                ),
              ],
            ),
          ],
        ),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: widget.book.chapters[widget.chapterIndex].length,
          itemBuilder: (context, verseIndex) {
            final verse = widget.book.chapters[widget.chapterIndex][verseIndex];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: GestureDetector(
                onLongPress: () {
                  Provider.of<BookmarkProvider>(context, listen: false)
                      .addBookmark(
                    '${widget.book.name} ${widget.chapterIndex + 1}:${verseIndex + 1} - $verse',
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Verse added to bookmarks'),
                    ),
                  );
                },
                onTap: () {
                  if (isPlaying && currentPlayingVerseIndex == verseIndex) {
                    flutterTts.stop();
                    setState(() {
                      isPlaying = false;
                      currentPlayingVerseIndex = null;
                    });
                  } else {
                    speakVerse(verse, verseIndex);
                  }
                },
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
                          color: currentPlayingVerseIndex == verseIndex
                              ? Colors.blue
                              : Colors.black,
                          backgroundColor:
                              widget.highlightedVerseIndex == verseIndex &&
                                      widget.highlightedText != null &&
                                      verse.toLowerCase().contains(
                                          widget.highlightedText!.toLowerCase())
                                  ? Colors.yellow
                                  : Colors.transparent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void speakChapter() {
    StringBuffer chapterText = StringBuffer();
    for (var verseIndex = 0;
        verseIndex < widget.book.chapters[widget.chapterIndex].length;
        verseIndex++) {
      chapterText
          .write("${widget.book.chapters[widget.chapterIndex][verseIndex]} ");
    }
    speakVerse(chapterText.toString(), -1);
  }

  Future<void> showSpeedPitchDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Adjust Speed and Pitch'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Slider(
                value: speed,
                min: 0.5,
                max: 2.0,
                divisions: 15,
                label: 'Speed: $speed',
                onChanged: (value) {
                  setState(() {
                    speed = value;
                  });
                },
              ),
              Slider(
                value: pitch,
                min: 0.5,
                max: 2.0,
                divisions: 15,
                label: 'Pitch: $pitch',
                onChanged: (value) {
                  setState(() {
                    pitch = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
