import 'package:flutter/material.dart';
import 'package:saint_paul/core/models/student_model.dart';

class StudentInfoEditScreen extends StatefulWidget {
  const StudentInfoEditScreen({super.key, required this.student});
  final StudentModel student;

  @override
  State<StudentInfoEditScreen> createState() => _StudentInfoEditScreenState();
}

class _StudentInfoEditScreenState extends State<StudentInfoEditScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
