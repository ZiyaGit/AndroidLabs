import 'package:flutter/material.dart';
import 'database.dart';
import 'todo.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final database = await $FloorAppDatabase
      .databaseBuilder('app_database.db')
      .build();

  runApp(MyApp(database));
}

class MyApp extends StatelessWidget {
  final AppDatabase database;

  MyApp(this.database);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(database),
    );
  }
}

class HomePage extends StatefulWidget {
  final AppDatabase database;

  HomePage(this.database);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();
  List<Todo> _items = [];
  Todo? _selectedItem;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final items = await widget.database.todoDao.findAllTodos();
    setState(() {
      _items = items;
    });
  }

  void _addItem() async {
    if (_controller.text.isNotEmpty) {
      final newTodo = Todo(
        _items.isEmpty ? 1 : _items.last.id + 1,
        _controller.text,
      );
      await widget.database.todoDao.insertTodo(newTodo);
      setState(() {
        _items.add(newTodo);
        _controller.clear();
      });
    }
  }

  void _deleteItem(Todo item) async {
    await widget.database.todoDao.deleteTodo(item);
    setState(() {
      _items.remove(item);
      _selectedItem = null;
    });
  }

  void _showDeleteItemDialog(BuildContext context, Todo item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete this item?'),
          content: Text('Are you sure you want to delete this item?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () {
                _deleteItem(item);
                Navigator.of(context).pop();
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  Widget ToDoList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            ElevatedButton(
              onPressed: _addItem,
              child: Text('Add'),
            ),
            SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    borderSide: BorderSide(color: Colors.grey, width: 1.0),
                  ),
                  hintText: 'Enter a todo item',
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Expanded(
          child: _items.isEmpty
              ? Center(child: Text('There are no items in the list'))
              : ListView.builder(
            itemCount: _items.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedItem = _items[index];
                  });
                },
                onLongPress: () {
                  _showDeleteItemDialog(context, _items[index]);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey[300]!,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text('Row number: ${index + 1}'),
                      Text(_items[index].title),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget DetailsPage() {
    if (_selectedItem == null) return Container();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Item: ${_selectedItem!.title}'),
        Text('ID: ${_selectedItem!.id}'),
        ElevatedButton(
          onPressed: () {
            _deleteItem(_selectedItem!);
          },
          child: Text('Delete'),
        ),
      ],
    );
  }

  Widget responsiveLayout() {
    var size = MediaQuery.of(context).size;
    var height = size.height;
    var width = size.width;

    if (width > height && width > 600) {
      return Row(
        children: [
          Expanded(flex: 1, child: ToDoList()),
          Expanded(flex: 1, child: Center(child: DetailsPage())),
        ],
      );
    } else {
      if (_selectedItem != null) {
        return DetailsPage();
      } else {
        return ToDoList();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text('Flutter Demo Home Page'),
        backgroundColor: Color(0xFFD1C4E9),
      ),
      body: responsiveLayout(),
    );
  }
}
