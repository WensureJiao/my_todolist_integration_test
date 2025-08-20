import 'package:demo/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:demo/pages/todo_list_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TodoListPage 关键逻辑测试', () {
    //setUp() 里的代码会在每个testwidget测试前执行，保证测试环境一致。
    setUp(() async {
      SharedPreferences.setMockInitialValues({}); // 清空 SharedPreferences
    });

    // ---------- 添加 Todo ----------
    testWidgets('添加 Todo 正向', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: TodoApp()));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).at(0), '添加正向');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('添加正向'), findsOneWidget);
    });

    testWidgets('添加 Todo 反向（空标题）', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: TodoApp()));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save')); // 空标题直接保存
      await tester.pumpAndSettle();

      // 弹出 SnackBar 提示
      expect(find.text('Title is required'), findsOneWidget);
    });

    // ---------- 删除 Todo ----------
    testWidgets('删除 Todo 正向', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: TodoApp()));
      await tester.pumpAndSettle();

      // 添加 Todo
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).at(0), '删除正向');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // 删除
      await tester.tap(find.byKey(const Key('todo_actions')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Delete'));
      await tester.pumpAndSettle();

      expect(find.text('删除正向'), findsNothing);
      expect(find.text('No TODOs yet'), findsOneWidget);
    });

    testWidgets('删除 Todo 反向（空列表删除）', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: TodoApp()));
      await tester.pumpAndSettle();

      // 尝试点击删除按钮，但列表为空，不会报错
      expect(find.byKey(const Key('todo_actions')), findsNothing);
    });

    // ---------- 排序 ----------
    testWidgets('排序 Todo 正向', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: TodoApp()));
      await tester.pumpAndSettle();

      // 添加两个 Todo
      for (var title in ['B', 'A']) {
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField).at(0), title);
        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();
      }

      final listFinder = find.byKey(const Key('todo_list'));
      final firstItem = find
          .descendant(of: listFinder, matching: find.byType(ListTile))
          .first;

      // 正向：按 title 排序
      expect(
        find.descendant(of: firstItem, matching: find.text('A')),
        findsOneWidget,
      );
    });

    testWidgets('排序 Todo 反向（空列表排序）', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: TodoApp()));
      await tester.pumpAndSettle();

      // 列表为空，排序按钮不会显示
      expect(find.byKey(const Key('sort_menu')), findsNothing);
    });

    // ---------- 修改状态 ----------
    testWidgets('修改 Todo 状态 正向', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: TodoApp()));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).at(0), '状态正向');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('todo_status')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('progress').last);
      await tester.pumpAndSettle();

      expect(find.text('progress'), findsOneWidget);
    });

    testWidgets('修改 Todo 状态 反向（列表为空）', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: TodoApp()));
      await tester.pumpAndSettle();

      // 空列表，没有状态下拉
      expect(find.byKey(const Key('todo_status')), findsNothing);
    });
  });
}
