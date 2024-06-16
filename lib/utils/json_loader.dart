import 'dart:convert';
import 'package:bible_app/models/book.dart';
import 'package:flutter/services.dart';


Future<List<Book>> loadBooks() async {
  final String response = await rootBundle.loadString('assets/en_kjv.json');
  final List<dynamic> data = json.decode(response);

  return data.map((json) => Book.fromJson(json)).toList();
}
