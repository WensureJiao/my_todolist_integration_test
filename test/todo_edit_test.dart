import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:demo/models/todo.dart';
import 'package:demo/pages/todo_edit_page.dart';

void main() {
  group('TodoEditPage 关键行为测试', () {
    //  正向测试
    testWidgets('输入有效 title 后保存 Todo 成功', (WidgetTester tester) async {
      late Todo savedTodo;

      await tester.pumpWidget(
        MaterialApp(home: TodoEditPage(onSave: (t) => savedTodo = t)),
      );

      // 输入有效 title
      await tester.enterText(find.byType(TextField).at(0), '新 Todo');
      await tester.enterText(find.byType(TextField).at(1), '副标题');
      await tester.enterText(find.byType(TextField).at(2), '描述');

      // 点击 Save
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle(); //持续调用 pump()，直到没有动画或微任务在进行，界面稳定为止。

      // 断言回调返回的 Todo
      expect(savedTodo.title, '新 Todo');
      expect(savedTodo.subtitle, '副标题');
      expect(savedTodo.description, '描述');
      expect(savedTodo.status, TodoStatus.waiting); // 默认状态
    });

    testWidgets('初始化已有 Todo 时文本框正确填充', (WidgetTester tester) async {
      final todo = Todo(
        title: '标题',
        subtitle: '副标题',
        description: '描述',
        status: TodoStatus.progress,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: TodoEditPage(todo: todo, onSave: (_) {}),
        ),
      );

      // 检查 TextField 是否填充正确
      expect(find.widgetWithText(TextField, '标题'), findsOneWidget);
      expect(find.widgetWithText(TextField, '副标题'), findsOneWidget);
      expect(find.widgetWithText(TextField, '描述'), findsOneWidget);
    });

    //  反向测试

    testWidgets('title 为空时点击 Save 弹出 SnackBar', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: TodoEditPage(onSave: (_) {})));

      // title 为空
      await tester.enterText(find.byType(TextField).at(0), '');

      // 点击 Save
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // 验证 SnackBar 弹出
      expect(find.text('Title is required'), findsOneWidget);
    });
  });
}
