import 'package:flutter/material.dart';
import 'pages/todo_list_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter TODO',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const TodoListPage(),
    );
  }
}
