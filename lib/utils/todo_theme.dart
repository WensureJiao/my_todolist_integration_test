import 'package:flutter/material.dart';
import '../models/todo.dart';

class TodoTheme {
  /// 根据状态返回对应颜色
  static Color statusColor(TodoStatus status, bool isDark) {
    switch (status) {
      case TodoStatus.waiting:
        return isDark ? Colors.grey.shade700 : Colors.grey.shade300;
      case TodoStatus.progress:
        return isDark ? Colors.blue.shade700 : Colors.blue.shade300;
      case TodoStatus.done:
        return isDark ? Colors.green.shade700 : Colors.green.shade300;
    }
  }

  /// 根据主题返回文字颜色
  static Color textColor(bool isDark) => isDark ? Colors.white : Colors.black;

  /// 可选：根据亮暗主题返回阴影颜色
  static Color shadowColor(bool isDark) =>
      isDark ? Colors.black26 : Colors.black12;
}
