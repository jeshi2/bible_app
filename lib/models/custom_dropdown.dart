import 'package:bible_app/models/book.dart';
import 'package:flutter/material.dart';

class CustomDropdown extends StatefulWidget {
  final List<Book> books;
  final Book selectedBook;
  final ValueChanged<Book> onBookSelected;

  const CustomDropdown({
    Key? key,
    required this.books,
    required this.selectedBook,
    required this.onBookSelected,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _CustomDropdownState createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  late OverlayEntry _overlayEntry;
  late LayerLink _layerLink;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _layerLink = LayerLink();
  }

  @override
  void dispose() {
    if (_isOpen) {
      _closeDropdown();
    }
    super.dispose();
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;
    var screenHeight = MediaQuery.of(context).size.height;

    double dropdownHeight = 800.0;
    // Adjust the height if it exceeds the available space
    if (size.height + dropdownHeight > screenHeight) {
      dropdownHeight = screenHeight - size.height - 10.0;
    }

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height + 5.0),
          child: Material(
            elevation: 4.0,
            child: Container(
              height: dropdownHeight,
              color: Colors.white,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 3,
                ),
                itemCount: widget.books.length,
                itemBuilder: (context, index) {
                  Book book = widget.books[index];
                  return Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        backgroundColor: book == widget.selectedBook
                            ? Colors.orange
                            : Colors.teal,
                      ),
                      onPressed: () {
                        widget.onBookSelected(book);
                        _closeDropdown();
                      },
                      child: Text(
                        book.name,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openDropdown() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context)!.insert(_overlayEntry);
    setState(() {
      _isOpen = true;
    });
  }

  void _closeDropdown() {
    _overlayEntry.remove();
    setState(() {
      _isOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: () {
          if (_isOpen) {
            _closeDropdown();
          } else {
            _openDropdown();
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Expanded(
                child: Center(
                  child: Text(
                    widget.selectedBook.name,
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
              ),
              Icon(
                _isOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                color: Colors.teal,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
