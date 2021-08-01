import 'package:flutter/material.dart';
import 'package:todo_list/loding_container.dart';
import 'package:todo_list/sqlite/PersonDbProvider.dart';
import 'package:todo_list/sqlite/TodoModel.dart';
import 'package:todo_list/todo.dart';
import 'package:todo_list/new_todo_dialog.dart';

typedef ToggleTodoCallback = void Function(Todo, bool);

class TodoListScreen extends StatefulWidget {
  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  bool _loading = true;
  List<Todo> todos = [];

  _toggleTodo(Todo todo, bool isChecked) {
    setState(() {
      todo.isDone = isChecked;
    });
    update(todo);
  }

  _addTodo() async {
    setState(() {
      _loading = true;
    });
    final todo = await showDialog<Todo>(
      context: context,
      builder: (BuildContext context) {
        return NewTodoDialog();
      },//创建新任务
    );

    if (todo != null) {
      setState(() {
        todos.add(todo);
      });
    }
    setState(() {
      _loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    select();
  }

  select() async {
    PersonDbProvider provider = new PersonDbProvider();
    TodoModels todoModels = await provider.getUserInfo();
    try {
      todoModels.todoModel.forEach((model) {
        print(model);
        bool isDone = model.isDone == "true";
        print(isDone);
        todos.add(new Todo(title: model.title, id: model.id, isDone: isDone));
        print(todos);
      });
    } catch (e) {
      print(e);
    }
    ;
    setState(() {
      _loading = false;
    });
  }

  //修改(controller的值获取不到，只能传值获取)
  Future update(Todo todo) async {
    PersonDbProvider provider = new PersonDbProvider();
    TodoModel userModel = await provider.getPersonInfo();
    userModel.id = todo.id;
    userModel.isDone = todo.isDone.toString();
    userModel.title = todo.title;
    provider.update(userModel);
  }

  //删除
  Future delete(value) async {
    PersonDbProvider provider = new PersonDbProvider();
    TodoModel userModel = await provider.getPersonInfo();
    userModel.id = value;
    provider.delete(userModel);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo List'),
        actions: <Widget>[],
      ),
      body: LoadingContainer(
          isLoading: _loading, child: _createListView(todos, _toggleTodo)),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: _addTodo,
      ),
    );
  }

  // 创建ListView
  Widget _createListView(todos, onTodoToggle) {
    return ListView.builder(
      itemCount: todos.length,
      itemBuilder: (context, index) {
        return Dismissible(
          background: Container(
            color: Colors.green,
            // 这里使用 ListTile 因为可以快速设置左右两端的Icon
            child: ListTile(
              leading: Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
          ),

          secondaryBackground: Container(
            color: Colors.red,
            // 这里使用 ListTile 因为可以快速设置左右两端的Icon
            child: ListTile(
              trailing: Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
          ),
          // Key
          key: Key(UniqueKey().toString()),
          // Child
          child: CheckboxListTile(
            value: todos[index].isDone,
            activeColor: Colors.red,
            title: todos[index].isDone
                ? Text(
                    todos[index].title,
                    style: TextStyle(
                      color: Colors.grey,
                      decoration: TextDecoration.lineThrough,
                      decorationColor: Colors.grey,
                    ),//这个是点击后会变灰并加一条线
                  )
                : Text(todos[index].title),
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: (bool isChecked) {
              onTodoToggle(todos[index], isChecked);
            },
          ),
          onDismissed: (direction) {
            // 展示 SnackBar
//            Scaffold.of(context).showSnackBar(SnackBar(
//              content: Text('删除了${todos[index].title}'),
//            ));
            // 删除后刷新列表，以达到真正的删除
            delete(todos[index].id);
            setState(() {
              todos.removeAt(index);
            });
          },
          confirmDismiss: (direction) async {
            var _confirmContent;
            var _alertDialog;
            // 从右向左  也就是删除
            _confirmContent = '确认删除:${todos[index].title}？';
            _alertDialog = AlertDialog(
              title: Text(_confirmContent),
              actions: <Widget>[
                FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);//连带true一起返回
                  },
                  child: Text('确认'),
                ),
                FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text('取消'),
                )
              ],
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20))),
            );

//            else if (direction == DismissDirection.startToEnd) {
//              _confirmContent = '确认收藏${_listData[index]}？';
//              _alertDialog = _createDialog(
//                _confirmContent,
//                    () {
//                  // 展示 SnackBar
//                  Scaffold.of(context).showSnackBar(SnackBar(
//                    content: Text('确认收藏${_listData[index]}'),
//                    duration: Duration(milliseconds: 400),
//                  ));
//                  Navigator.of(context).pop(true);
//                },
//                    () {
//                  // 展示 SnackBar
//                  Scaffold.of(context).showSnackBar(SnackBar(
//                    content: Text('不收藏${_listData[index]}'),
//                    duration: Duration(milliseconds: 400),
//                  ));
//                  Navigator.of(context).pop(false);
//                },
//              );
//            }

            var isDismiss = await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return _alertDialog;
                });
            return isDismiss;//点了确认就确定删除
          },
        );
      },
    );
  }
}
