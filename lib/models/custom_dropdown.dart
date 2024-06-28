import 'package:bible_app/models/book.dart';
import 'package:flutter/material.dart';

class CustomDropdown extends StatefulWidget {
  final List<Book> books;
  final Book selectedBook;
  final ValueChanged<Book> onBookSelected;

  const CustomDropdown({
    super.key,
    required this.books,
    required this.selectedBook,
    required this.onBookSelected,
  });

  @override
  // ignore: library_private_types_in_public_api
  _CustomDropdownState createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
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
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) {
              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  height: 400.0,
                  child: Column(
                    children: [
                      Expanded(
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10.0,
                            mainAxisSpacing: 10.0,
                            childAspectRatio: 3,
                          ),
                          itemCount: widget.books.length,
                          itemBuilder: (context, index) {
                            Book book = widget.books[index];
                            return GestureDetector(
                              onTap: () {
                                widget.onBookSelected(book);
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15.0),
                                  border: Border.all(color: Colors.blue),
                                ),
                                child: Text(book.name),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        child: Row(
          children: [
            const Icon(Icons.menu, color: Colors.grey),
            Expanded(
              child: Center(
                child: Text(
                  widget.selectedBook.name,
                  style: const TextStyle(color: Colors.black),
                ),
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.grey),
            const Icon(Icons.search, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
