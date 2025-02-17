// Task Model
class Task {
  final int? id;
  final String title;
  final String description;
  final bool isCompleted;
  final DateTime? dueDate; // New field for the due date

  Task({
    this.id,
    required this.title,
    required this.description,
    this.isCompleted = false,
    this.dueDate, // New parameter
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted ? 1 : 0,
      'dueDate': dueDate?.toIso8601String(), // Convert DateTime to string
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      isCompleted: map['isCompleted'] == 1,
      dueDate: map['dueDate'] != null
          ? DateTime.parse(map['dueDate'])
          : null, // Convert string to DateTime
    );
  }

  Task copyWith({
    int? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? dueDate, // Add dueDate as a parameter
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: dueDate ?? this.dueDate, // Copy the dueDate
    );
  }
}