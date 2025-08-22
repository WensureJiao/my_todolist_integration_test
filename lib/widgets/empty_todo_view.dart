import 'package:flutter/material.dart';

class EmptyTodoView extends StatelessWidget {
  const EmptyTodoView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("No TODOs yet"));
  }
}
