import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/loading_view.dart';
import 'package:todo_app/todo_cubit.dart';

import 'models/Todo.dart';

class TodosView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TodosViewState();
}

class _TodosViewState extends State<TodosView> {
  final _titleController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: _navBar(),
        floatingActionButton: _floatingActionButton(),
        body: BlocBuilder<TodoCubit, TodoState>(builder: (context, state) {
          if (state is ListTodosSuccess) {
            return state.todos.isEmpty
                ? _emptyTodosView()
                : _todosListView(state.todos);
          } else if (state is ListTodosFailure) {
            return _exceptionView(state.exception);
          } else {
            return LoadingView();
          }
        }));
  }

  Widget _exceptionView(Exception exception) {
    return Center(child: Text(exception.toString()));
  }

  AppBar _navBar() {
    return AppBar(
      title: Text('Todo App'),
      centerTitle: true,
    );
  }

  Widget _newTodoView() {
    return Column(
      children: [
        TextField(
          controller: _titleController,
          decoration: InputDecoration(hintText: 'Enter Todo title'),
        ),
        ElevatedButton(onPressed: _addTodo, child: Text('Save Todo'))
      ],
    );
  }

  Widget _floatingActionButton() {
    return FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
              context: context,
              builder: (BuildContext context) => _newTodoView());
        },
        tooltip: 'Add Todo',
        child: Icon(Icons.add));
  }

  Widget _emptyTodosView() {
    return Center(child: Text('No todos yet'));
  }

  Widget _todosListView(List<Todo> todos) {
    return ListView.builder(
        itemCount: todos.length,
        itemBuilder: (context, index) {
          final todo = todos[index];
          return Card(
            child: CheckboxListTile(
                title: Text(todo.title),
                value: todo.isComplete,
                onChanged: (newValue) {
                  BlocProvider.of<TodoCubit>(context)
                      .updateTodoIsComplete(todo, newValue!);
                }),
          );
        });
  }

  void _addTodo() {
    BlocProvider.of<TodoCubit>(context).createTodo(_titleController.text);
    _titleController.text = '';
    Navigator.of(context).pop();
  }
}
