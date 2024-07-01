import 'package:bible_app/screens/bookmark_page.dart';
import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  final List<String> bookmarks;
  const AppDrawer({super.key, required this.bookmarks});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              //color: Colors.teal,
              image: DecorationImage(
                image: AssetImage('assets/images/bible.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Text(
              'Bible',
              style: TextStyle(
                color: Colors.teal,
                fontWeight: FontWeight.w900,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.bookmark, color: Colors.teal),
            title: const Text('Bookmarks'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BookmarkScreen(bookmarks: bookmarks),
                ),
              );
            },
          ),
          ListTile(
            title: const Text('Item 2'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Item 2'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Item 2'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
