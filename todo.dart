import 'package:floor/floor.dart';

@entity
class Todo {
  @primaryKey
  final int id;
  final String title;

  Todo(this.id, this.title);
}