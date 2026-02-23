import 'package:flutter/material.dart';
import 'package:saint_paul/core/models/student_model.dart';

class StudentInfoScreen extends StatefulWidget {
  const StudentInfoScreen({super.key, required this.student});
  final StudentModel student;

  @override
  State<StudentInfoScreen> createState() => _StudentInfoScreenState();
}

class _StudentInfoScreenState extends State<StudentInfoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
