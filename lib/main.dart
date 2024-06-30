import 'dart:convert';
import 'dart:ui';
import 'package:bible_app/models/book.dart';
import 'package:bible_app/models/custom_dropdown.dart';
import 'package:bible_app/screens/chpater_screen.dart';
import 'package:bible_app/utils/app_drawer.dart';
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
  // ignore: prefer_final_fields
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
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

  void onBookSelected(Book book) {
    setState(() {
      selectedBook = book;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
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
                      scaffoldKey: _scaffoldKey,
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
      drawer: const AppDrawer(), 
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

class RoundedRectangle extends StatefulWidget {
  final List<Book> books;
  final Book selectedBook;
  final ValueChanged<Book> onBookSelected;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const RoundedRectangle({
    Key? key,
    required this.books,
    required this.selectedBook,
    required this.onBookSelected,
    required this.scaffoldKey,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _RoundedRectangleState createState() => _RoundedRectangleState();
}

class _RoundedRectangleState extends State<RoundedRectangle> {
  late TextEditingController _searchController;
  List<Book> filteredBooks = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    filteredBooks = widget.books;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void searchBooks(String query) {
    setState(() {
      filteredBooks = widget.books
          .where(
              (book) => book.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void openDrawer() {
    widget.scaffoldKey.currentState!.openDrawer();
  }

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
            // Sidemenu icon
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.teal),
              onPressed: () {
                widget.scaffoldKey.currentState!
                    .openDrawer(); // Open the drawer
              },
            ),
            
            Expanded(
              child: Center(
                child: CustomDropdown(
                  books: filteredBooks,
                  selectedBook: widget.selectedBook,
                  onBookSelected: widget.onBookSelected,
                  onChapterSelected: (int value) {},
                ),
              ),
            ),
            // Search Icon
            IconButton(
              icon: const Icon(Icons.search, color: Colors.teal),
              onPressed: () {
                showSearch(
                  context: context,
                  delegate:
                      BookSearchDelegate(widget.books, widget.onBookSelected),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class BookSearchDelegate extends SearchDelegate<void> {
  final List<Book> books;
  final ValueChanged<Book> onBookSelected;
  bool isSearching = false;
  int totalOccurrences = 0;

  BookSearchDelegate(this.books, this.onBookSelected);

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.teal, // Set AppBar background color to teal
        foregroundColor:
            Colors.white, // Set AppBar text and icons color to white
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(
            color: Colors.white), // Set the search text color to white
      ),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle:
            TextStyle(color: Colors.white), // Set the hint text color to white
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    totalOccurrences = 0;
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    totalOccurrences = 0;
    return query.isEmpty
        ? const Center(
            child: Text(
              'Type a word to search in the Bible',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          )
        : _buildSearchResults();
  }

  Widget _buildSearchResults() {
    if (query.isEmpty) {
      return Container();
    }

    isSearching = true;

    final List<Map<String, dynamic>> matchedVerses = [];

    for (var book in books) {
      for (var chapterIndex = 0;
          chapterIndex < book.chapters.length;
          chapterIndex++) {
        for (var verseIndex = 0;
            verseIndex < book.chapters[chapterIndex].length;
            verseIndex++) {
          final verse = book.chapters[chapterIndex][verseIndex];
          if (verse.toLowerCase().contains(query.toLowerCase())) {
            matchedVerses.add({
              'book': book,
              'chapterIndex': chapterIndex,
              'verseIndex': verseIndex,
              'verse': verse,
            });
            totalOccurrences++;
          }
        }
      }
    }

    isSearching = false;

    if (matchedVerses.isEmpty) {
      return Center(
        child: Text(
          'No results found for "$query"',
          style: const TextStyle(fontSize: 18, color: Colors.red),
        ),
      );
    }

    return isSearching
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 10),
                Text("Please wait..."),
              ],
            ),
          )
        : Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total occurrences of "$query": $totalOccurrences',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: matchedVerses.length,
                    itemBuilder: (context, index) {
                      final match = matchedVerses[index];
                      final Book book = match['book'];
                      final int chapterIndex = match['chapterIndex'];
                      final int verseIndex = match['verseIndex'];
                      final String verse = match['verse'];

                      return Card(
                        elevation: 2.0,
                        child: ListTile(
                          title: Text(
                            '${book.name} ${chapterIndex + 1}:${verseIndex + 1}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: RichText(
                            text: TextSpan(
                              text: '',
                              style: DefaultTextStyle.of(context).style,
                              children: _highlightOccurrences(verse, query),
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChapterScreen(
                                  book: book,
                                  chapterIndex: chapterIndex,
                                  highlightedVerseIndex: verseIndex,
                                  highlightedText: query,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
  }

  List<TextSpan> _highlightOccurrences(String text, String query) {
    final List<TextSpan> spans = [];
    int start = 0;
    int indexOfHighlight;

    while ((indexOfHighlight =
            text.toLowerCase().indexOf(query.toLowerCase(), start)) !=
        -1) {
      if (indexOfHighlight > start) {
        spans.add(TextSpan(text: text.substring(start, indexOfHighlight)));
      }
      spans.add(TextSpan(
        text: text.substring(indexOfHighlight, indexOfHighlight + query.length),
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
      ));
      start = indexOfHighlight + query.length;
    }

    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }

    return spans;
  }
}
