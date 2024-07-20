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

  void _deleteItem(int index) async {
    await widget.database.todoDao.deleteTodo(_items[index]);
    setState(() {
      _items.removeAt(index);
    });
  }

  void _showDeleteItemDialog(BuildContext context, int index) {
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
                _deleteItem(index);
                Navigator.of(context).pop();
              }, child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text('Flutter Demo Home Page'),
        backgroundColor: Color(0xFFD1C4E9),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, children: [
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
                    onLongPress: () {
                      // Pass context here
                      _showDeleteItemDialog(context, index);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom:
                          BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text('Row number: ${index+1}'),
                          Text(_items[index].title),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
