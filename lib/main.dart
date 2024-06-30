import 'dart:convert';
import 'dart:ui';
import 'package:bible_app/models/book.dart';
import 'package:bible_app/models/custom_dropdown.dart';
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
  void onBookSelected(Book book) {
    setState(() {
      selectedBook = book;
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

class RoundedRectangle extends StatefulWidget {
  final List<Book> books;
  final Book selectedBook;
  final ValueChanged<Book> onBookSelected;

  const RoundedRectangle({
    Key? key,
    required this.books,
    required this.selectedBook,
    required this.onBookSelected,
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
          .where((book) => book.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
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
            const Icon(Icons.menu, color: Colors.teal),
            Expanded(
              child: Center(
                child: CustomDropdown(
                  books: filteredBooks,
                  selectedBook: widget.selectedBook,
                  onBookSelected: widget.onBookSelected, onChapterSelected: (int value) {  },
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.search, color: Colors.teal),
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: BookSearchDelegate(widget.books, widget.onBookSelected),
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

  BookSearchDelegate(this.books, this.onBookSelected);

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.teal, // Set AppBar background color to teal
        foregroundColor: Colors.white, // Set AppBar text and icons color to white
      ),
      textTheme: const TextTheme(
        
        titleLarge: TextStyle(color: Colors.white), // Set the search text color to white
      ),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.white), // Set the hint text color to white
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
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    final List<Book> matchedBooks = query.isEmpty
        ? books
        : books
            .where((book) =>
                book.name.toLowerCase().contains(query.toLowerCase()))
            .toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0), // Padding added to search results
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Increased crossAxisCount to make boxes smaller
          mainAxisSpacing: 8.0,
          crossAxisSpacing: 8.0,
          childAspectRatio: 4.0, // Adjusted aspect ratio to make boxes smaller
        ),
        itemCount: matchedBooks.length,
        itemBuilder: (context, index) {
          final Book book = matchedBooks[index];
          return GestureDetector(
            onTap: () {
              onBookSelected(book);
              close(context, null);
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(16.0), // Rounded corners
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 4,
                    offset: const Offset(0, 2), // changes position of shadow
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  book.name,
                  style: const TextStyle(fontSize: 14.0, color: Colors.white), // Adjust font size to fit smaller box
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}