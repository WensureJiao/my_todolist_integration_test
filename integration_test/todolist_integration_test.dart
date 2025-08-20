import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:demo/main.dart' as app;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('TODO List 集成测试', () {
    testWidgets('添加、编辑、删除、排序 todo 测试', (WidgetTester tester) async {
      // 启动 app
      SharedPreferences.setMockInitialValues({}); // 清空本地数据模拟
      app.main();
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 1));
      await tester.pumpAndSettle();

      // 1. 验证初始无 todo
      expect(find.text('No TODOs yet'), findsOneWidget);
      await Future.delayed(Duration(seconds: 1));

      // 2. 添加第一个 todo
      final addButton = find.byIcon(Icons.add);
      await tester.tap(addButton);
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 1));

      await tester.enterText(find.byType(TextField).at(0), '测试Todo1');
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 1));

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 1));

      expect(find.text('测试Todo1'), findsOneWidget);
      await Future.delayed(Duration(seconds: 1));

      // 3. 编辑 todo
      final actionsButton = find.byKey(const Key('todo_actions'));
      await tester.tap(actionsButton);
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 1));

      final editMenuItem = find.text('Edit');
      await tester.tap(editMenuItem);
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 1));

      await tester.enterText(find.byType(TextField).at(0), '测试Todo1-编辑后');
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 1));

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 1));

      final todoList = find.byKey(const Key('todo_list'));
      expect(todoList, findsOneWidget);
      expect(find.text('测试Todo1-编辑后'), findsOneWidget);
      expect(find.text('测试Todo1'), findsNothing);
      await Future.delayed(Duration(seconds: 1));

      // 4. 修改状态
      final dropdown = find.byKey(const Key('todo_status'));
      await tester.tap(dropdown);
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 1));

      final progressItem = find.text('progress').last;
      await tester.tap(progressItem);
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 1));

      expect(find.text('progress'), findsOneWidget);
      await Future.delayed(Duration(seconds: 1));

      // 5. 添加第二个 todo 用于排序
      await tester.tap(addButton);
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 1));

      await tester.enterText(find.byType(TextField).at(0), 'A-排序测试');
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 1));

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 1));

      expect(find.text('A-排序测试'), findsOneWidget);
      await Future.delayed(Duration(seconds: 1));

      // 6. 排序 todo 按 title
      final sortMenuButton = find.byKey(const Key('sort_menu'));
      await tester.tap(sortMenuButton);
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 1));

      final titleSortOption = find.text('title').last;
      await tester.tap(titleSortOption);
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 1));

      final firstTodoTitleFinder = find
          .descendant(
            of: find.byType(ListView),
            matching: find.byType(ListTile),
          )
          .first;

      expect(
        find.descendant(
          of: firstTodoTitleFinder,
          matching: find.text('A-排序测试'),
        ),
        findsOneWidget,
      );
      await Future.delayed(Duration(seconds: 1));

      // 7. 删除第一个 todo
      await tester.tap(find.byKey(const Key('todo_actions')).at(0));
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 1));

      await tester.tap(find.text('Delete').first);
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 1));

      final confirmDeleteButton = find
          .widgetWithText(TextButton, 'Delete')
          .last;
      await tester.tap(confirmDeleteButton);
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 1));

      // 验证删除成功
      expect(find.text('A-排序测试'), findsNothing);
      expect(find.text('测试Todo1-编辑后'), findsOneWidget);
      await Future.delayed(Duration(seconds: 1));
    });
  });
}
