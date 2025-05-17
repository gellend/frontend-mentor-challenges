import 'package:cloud_firestore/cloud_firestore.dart';

class Todo {
  final String? id; // Nullable if creating a new Todo before it has an ID from Firestore
  final String userId;
  final String text;
  final bool isCompleted;
  final Timestamp createdAt;
  final int orderIndex; 

  Todo({
    this.id,
    required this.userId,
    required this.text,
    this.isCompleted = false, // Default to not completed
    required this.createdAt,
    required this.orderIndex,
  });

  // Factory constructor to create a Todo from a Firestore DocumentSnapshot
  factory Todo.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Todo(
      id: doc.id,
      userId: data['userId'] as String,
      text: data['text'] as String,
      isCompleted: data['isCompleted'] as bool,
      createdAt: data['createdAt'] as Timestamp,
      orderIndex: data['orderIndex'] as int? ?? 0, // Default to 0 if null, though should be set
    );
  }

  // Method to convert a Todo instance to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'text': text,
      'isCompleted': isCompleted,
      'createdAt': createdAt,
      'orderIndex': orderIndex,
    };
  }

  // Optional:copyWith method for easier updates
  Todo copyWith({
    String? id,
    String? userId,
    String? text,
    bool? isCompleted,
    Timestamp? createdAt,
    int? orderIndex,
  }) {
    return Todo(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      text: text ?? this.text,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }
} 