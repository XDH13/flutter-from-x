import 'package:flutter/material.dart';
import 'package:todo_list/todo.dart';

typedef ToggleTodoCallback = void Function(Todo, bool);

class TodoList extends StatelessWidget {
  TodoList({@required this.todos, this.onTodoToggle});

  final List<Todo> todos;
  final ToggleTodoCallback onTodoToggle;

  Widget _buildItem(BuildContext context, int index) {
    final todo = todos[index];
    return CheckboxListTile(
      value: todo.isDone,
      activeColor: Colors.red,
      title: todo.isDone
          ? Text(
              todo.title,
              style: TextStyle(
                color: Colors.grey,
                decoration: TextDecoration.lineThrough,
                decorationColor: Colors.grey,
              ),
            )
          : Text(todo.title),
      controlAffinity: ListTileControlAffinity.leading,
      onChanged: (bool isChecked) {
        onTodoToggle(todo, isChecked);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return  ListView.builder(//Listview的组成
      itemBuilder: _buildItem,
      itemCount: todos.length,
    );
  }
}
