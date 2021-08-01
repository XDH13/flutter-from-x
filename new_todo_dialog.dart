import 'package:flutter/material.dart';
import 'package:todo_list/sqlite/PersonDbProvider.dart';
import 'package:todo_list/sqlite/TodoModel.dart';
import 'package:todo_list/todo.dart';

class NewTodoDialog extends StatelessWidget {
  final controller = new TextEditingController();

  //增加（不需要id 自增）
  Future insert(String value) async{
    PersonDbProvider provider = new PersonDbProvider();//传送点。等我看完 todo PersonDbProvider
    TodoModel userModel= TodoModel();//传送点。等我看完 todo Model
   // userModel.id=int.parse(controller.value.text);
    userModel.title=value;
    userModel.isDone="false";
    return provider.insert(userModel);
  }
  //修改(controller的值获取不到，只能传值获取)
  Future update(String value) async{
    PersonDbProvider provider = new PersonDbProvider();
    TodoModel userModel= await provider.getPersonInfo();
//    userModel.id=int.parse(value);
//    userModel.mobile="00000";
    provider.update(userModel);
  }
  //删除
  Future delete(String value) async{
    PersonDbProvider provider = new PersonDbProvider();
    TodoModel userModel= await provider.getPersonInfo();
    userModel.id=int.parse(value);
    provider.delete(userModel);
  }
  //查询
  Future select()async{
    PersonDbProvider provider = new PersonDbProvider();
    TodoModels todoModels= await provider.getUserInfo();
    todoModels.todoModel.forEach((model){
      print(model);
    });
  }


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('New todo'),
      content: TextField(
        controller: controller,
        autofocus: true,
      ),
      actions: <Widget>[
        FlatButton(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        FlatButton(
          child: Text('Add'),
          onPressed: () async {
//            select();
//            update(controller.value.text);
            int lastID = await insert(controller.value.text);
            print(lastID);
//            delete(controller.value.text);
            final todo = new Todo(title: controller.value.text,id:lastID );
            controller.clear();
            Navigator.of(context).pop(todo);
          },
        ),
      ],
    );
  }
}
