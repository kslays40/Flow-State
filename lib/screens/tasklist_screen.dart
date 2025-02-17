import 'package:flow_state/models/task_model.dart';
import 'package:flow_state/services/task_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';

class TaskListScreen extends ConsumerWidget {
  final VoidCallback onThemeToggle; // Callback function for theme toggle

  const TaskListScreen({super.key, required this.onThemeToggle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(taskListProvider);
    final taskNotifier = ref.read(taskListProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: Text('Flow State',style: TextStyle(fontWeight: FontWeight.bold),),
        actions: [
          // Add a button for theme toggle
          IconButton(
            icon: Icon(CupertinoIcons.cloud_sun_fill),
            onPressed: onThemeToggle, // Trigger theme toggle
          ),
          PopupMenuButton<TaskStatus>(
            icon: Icon(Icons.sort_rounded),
            onSelected: (status) {
              taskNotifier.setFilter(status);
            },
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  value: TaskStatus.all,
                  child: Text('All Tasks'),
                ),
                PopupMenuItem(
                  value: TaskStatus.completed,
                  child: Text('Completed Tasks'),
                ),
                PopupMenuItem(
                  value: TaskStatus.pending,
                  child: Text('Pending Tasks'),
                ),
              ];
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return Card(
            color: task.isCompleted ? Colors.purple[100] : Colors.white,
            margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: ListTile(
              textColor: Colors.black,
              iconColor: Colors.black,
              title: Text(task.title,style: TextStyle(fontWeight: FontWeight.bold),overflow: TextOverflow.ellipsis,),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(task.description,overflow: TextOverflow.ellipsis,),
                  if (task.dueDate != null)
                    Text(
                        'Due: ${task.dueDate!.toLocal().toString().split(' ')[0]}',overflow: TextOverflow.ellipsis,),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Update Task
                  IconButton(
                    icon: Icon(CupertinoIcons.hand_draw_fill),
                    onPressed: () {
                      _showUpdateTaskDialog(context, ref, task);
                    },
                  ),
                  // Delete Task
                  IconButton(
                    icon: Icon(CupertinoIcons.trash_fill),
                    onPressed: () {
                      ref.read(taskListProvider.notifier).deleteTask(task.id!);
                      _showDoneDialog(context);
                    },
                  ),
                ],
              ),
              onTap: () {
                ref.read(taskListProvider.notifier).updateTask(
                      task.copyWith(isCompleted: !task.isCompleted),
                    );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTaskDialog(context, ref);
        },
        backgroundColor: Colors.purple[100],
        child: Icon(Icons.add,color: Colors.black,),
      ),
    );
  }

  // Method to show the "Done" dialog
  void _showDoneDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return GestureDetector(
          onTap: (){
            Navigator.of(context).pop();
          },
          child: AlertDialog(
              backgroundColor: Colors.transparent,
              content: Lottie.asset('assets/Done2.json'),
            ),
        );
      },
      
    );
  }

  void _showAddTaskDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime? selectedDueDate;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Task',style: TextStyle(fontWeight: FontWeight.bold),),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(10.0), // Set the border radius
                    ),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(10.0), // Set the border radius
                    ),
                  ),
                ),
                Row(
                  children: [
                    Text('Due Date:'),
                    IconButton(
                      icon: Icon(CupertinoIcons.calendar),
                      onPressed: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (pickedDate != null) {
                          selectedDueDate = pickedDate;
                        }
                      },
                    ),
                    Text(selectedDueDate != null
                        ? selectedDueDate!.toLocal().toString().split(' ')[0]
                        : 'Not selected'),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final task = Task(
                  title: titleController.text,
                  description: descriptionController.text,
                  dueDate: selectedDueDate, // Pass the due date
                );
                ref.read(taskListProvider.notifier).addTask(task);
                Navigator.of(context).pop();
                _showDoneDialog(context);
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showUpdateTaskDialog(BuildContext context, WidgetRef ref, Task task) {
    final titleController = TextEditingController(text: task.title);
    final descriptionController = TextEditingController(text: task.description);
    DateTime? selectedDueDate = task.dueDate;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Update Task',style: TextStyle(fontWeight: FontWeight.bold),),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(10.0), // Set the border radius
                    ),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(10.0), // Set the border radius
                    ),
                  ),
                ),
                Row(
                  children: [
                    Text('Due Date:'),
                    IconButton(
                      icon: Icon(CupertinoIcons.calendar),
                      onPressed: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: selectedDueDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (pickedDate != null) {
                          selectedDueDate = pickedDate;
                        }
                      },
                    ),
                    Text(selectedDueDate != null
                        ? selectedDueDate!.toLocal().toString().split(' ')[0]
                        : 'Not selected'),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final updatedTask = task.copyWith(
                  title: titleController.text,
                  description: descriptionController.text,
                  dueDate: selectedDueDate, // Update the due date
                );
                ref.read(taskListProvider.notifier).updateTask(updatedTask);
                Navigator.of(context).pop();
                _showDoneDialog(context);
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }
}