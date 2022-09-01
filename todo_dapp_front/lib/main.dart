import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_dapp_front/TodoList.dart';
import 'package:todo_dapp_front/TodoListModel.dart';

import 'package:todo_dapp_front/pages/LoginPage.dart';
import 'package:todo_dapp_front/utils/routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TodoListModel(),
      child: MaterialApp(
        initialRoute: MyRoutes.loginRoute,
        title: 'Flutter TODO',
        routes: {
          MyRoutes.loginRoute: (context) => const LoginPage(),
          MyRoutes.todoListRoute: (context) => const TodoList(),
        },
        // home: TodoList()
      ),
    );
  }
}