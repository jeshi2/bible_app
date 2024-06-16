import 'package:bible_app/models/book.dart';
import 'package:bible_app/utils/json_loader.dart';
import 'package:flutter/material.dart';

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
  late Future<List<Book>> futureBooks;
  Book? selectedBook;

  @override
  void initState() {
    super.initState();
    futureBooks = loadBooks();
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
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: FutureBuilder<List<Book>>(
                future: futureBooks,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('No books found');
                  } else {
                    selectedBook ??= snapshot.data!.first;
                    return RoundedRectangle(
                      books: snapshot.data!,
                      selectedBook: selectedBook!,
                      onBookSelected: (book) {
                        setState(() {
                          selectedBook = book;
                        });
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
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
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      ...selectedBook!.chapters[chapterIndex].asMap().entries.map((entry) {
                        int verseIndex = entry.key;
                        String verse = entry.value;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '${verseIndex + 1} ',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                                ),
                                TextSpan(
                                  text: verse,
                                  style: const TextStyle(fontSize: 16, color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                );
              },
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}

class RoundedRectangle extends StatelessWidget {
  final List<Book> books;
  final Book selectedBook;
  final ValueChanged<Book> onBookSelected;

  const RoundedRectangle({super.key, required this.books, required this.selectedBook, required this.onBookSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.0,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25.0),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            const Icon(Icons.menu, color: Colors.grey),
            Expanded(
              child: Center(
                child: DropdownButton<Book>(
                  value: selectedBook,
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
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
            const Icon(Icons.search, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}