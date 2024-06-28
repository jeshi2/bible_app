import 'dart:convert';
import 'dart:ui';
import 'package:bible_app/models/book.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

void main() {
  runApp(const BibleApp());
}

class BibleApp extends StatelessWidget {
  const BibleApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bible App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Book> books = [];
  Book? selectedBook;

  @override
  void initState() {
    super.initState();
    loadBooks();
  }

  // Load Books from json file
  void loadBooks() async {
    final String response = await rootBundle.loadString('assets/en_bbe.json');
    final List<dynamic> data = json.decode(response);
    setState(() {
      books = data.map((json) => Book.fromJson(json)).toList();
      selectedBook = books.isNotEmpty ? books.first : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        toolbarHeight: 100.0,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: books.isNotEmpty
                  ? RoundedRectangle(
                      books: books,
                      selectedBook: selectedBook!,
                      onBookSelected: (book) {
                        setState(() {
                          selectedBook = book;
                        });
                      },
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
      // Chapter display
      body: selectedBook != null
          ? ListView.builder(
              itemCount: selectedBook!.chapters.length,
              itemBuilder: (context, chapterIndex) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Chapter ${chapterIndex + 1}',
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: RichText(
                          text: TextSpan(
                            children: selectedBook!.chapters[chapterIndex]
                                .asMap()
                                .entries
                                .map((entry) {
                              int verseIndex = entry.key;
                              String verse = entry.value;
                              return TextSpan(
                                children: [
                                  // verses numbering
                                  TextSpan(
                                    text: '${verseIndex + 1} ',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                      fontFeatures: [
                                        FontFeature.superscripts()
                                      ],
                                    ),
                                  ),
                                  TextSpan(
                                    // verses content
                                    text: '$verse ',
                                    style: const TextStyle(
                                        fontSize: 16, color: Colors.black),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            )
          : const Center(
              child: Text('No books available'),
            ),
    );
  }
}

class RoundedRectangle extends StatelessWidget {
  final List<Book> books;
  final Book selectedBook;
  final ValueChanged<Book> onBookSelected;

  const RoundedRectangle(
      {super.key,
      required this.books,
      required this.selectedBook,
      required this.onBookSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.0,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25.0),
        boxShadow: const [
          BoxShadow(
            color: Colors.teal,
            blurRadius: 4.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            const Icon(Icons.menu, color: Colors.teal),
            Expanded(
              child: Center(
                child: DropdownButton<Book>(
                  value: selectedBook,
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.teal),
                  iconSize: 24,
                  elevation: 16,
                  style: const TextStyle(color: Colors.black),
                  underline: Container(
                    height: 0,
                  ),
                  onChanged: (Book? newValue) {
                    onBookSelected(newValue!);
                  },
                  items: books.map<DropdownMenuItem<Book>>((Book book) {
                    return DropdownMenuItem<Book>(
                      value: book,
                      child: Text(book.name),
                    );
                  }).toList(),
                ),
              ),
            ),
            const Icon(Icons.search, color: Colors.teal),
          ],
        ),
      ),
    );
  }
}
