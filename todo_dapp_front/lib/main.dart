import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_dapp_front/TodoList.dart';
import 'package:todo_dapp_front/TodoListModel.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TodoListModel(),
      child: const MaterialApp(
        title: 'Flutter TODO',
        home: TodoList()
      )
    );
  }
}