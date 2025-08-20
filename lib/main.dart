import 'package:flutter/material.dart';
import 'pages/todo_list_page.dart';
import 'pages/todo_setting_page.dart';

// 全局 notifier 用于刷新 List
final ValueNotifier<int> todoNotifier = ValueNotifier<int>(0);

void main() {
  runApp(const TodoApp());
}

class TodoApp extends StatefulWidget {
  const TodoApp({Key? key}) : super(key: key);

  @override
  State<TodoApp> createState() => _TodoAppState();
}

class _TodoAppState extends State<TodoApp> {
  ThemeMode _themeMode = ThemeMode.light; //默认亮色主题
  int _currentIndex = 0; //默认初始显示todolist页面

  void _toggleTheme() {
    // 切换主题
    setState(() {
      _themeMode = _themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo List',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: Scaffold(
        body: IndexedStack(
          // 使用 IndexedStack 来切换页面
          index:
              _currentIndex, // 根据 _currentIndex 切换页面，0表示 TodoListPage，1 表示 SettingPage
          children: [
            TodoListPage(todoNotifier: todoNotifier),
            SettingPage(
              refreshNotifier: todoNotifier,
              onToggleTheme: _toggleTheme,
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.list), label: "List"),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: "Setting",
            ),
          ],
        ),
      ),
    );
  }
}
