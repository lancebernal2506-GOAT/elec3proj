import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
void main() async {
WidgetsFlutterBinding.ensureInitialized();
await Firebase.initializeApp(
options: DefaultFirebaseOptions.currentPlatform,
);
runApp(const MyApp());
}
class MyApp extends StatelessWidget {
const MyApp({super.key});
@override
Widget build(BuildContext context) {
return const MaterialApp(
debugShowCheckedModeBanner: false,
home: StudentRegistrationPage(),
);
}
}
class StudentRegistrationPage extends StatefulWidget {
const StudentRegistrationPage({super.key});
@override
State<StudentRegistrationPage> createState() =>
_StudentRegistrationPageState();
}
class _StudentRegistrationPageState extends State<StudentRegistrationPage> {
final TextEditingController nameController = TextEditingController();
final TextEditingController courseController = TextEditingController();
final TextEditingController yearController = TextEditingController();
final TextEditingController studentNumberController = TextEditingController();
final TextEditingController collegeController = TextEditingController();
@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: const Text("Student Registration"),
),
body: SingleChildScrollView(
padding: const EdgeInsets.all(16.0),
child: Column(
children: [
TextField(
controller: nameController,
decoration: const InputDecoration(
labelText: "Student Name",
border: OutlineInputBorder(),
),
),
const SizedBox(height: 10),
TextField(
controller: courseController,
decoration: const InputDecoration(
labelText: "Course",
border: OutlineInputBorder(),
),
),
const SizedBox(height: 10),
TextField(
controller: yearController,
decoration: const InputDecoration(
labelText: "Year Level",
border: OutlineInputBorder(),
),
),
const SizedBox(height: 10),
TextField(
controller: studentNumberController,
decoration: const InputDecoration(
labelText: "Student Number",
border: OutlineInputBorder(),
),
),
const SizedBox(height: 10),
TextField(
controller: collegeController,
decoration: const InputDecoration(
labelText: "College",
border: OutlineInputBorder(),
),
),
const SizedBox(height: 20),
ElevatedButton(
onPressed: () async {
await FirebaseFirestore.instance.collection('students').add({
'name': nameController.text,
'course': courseController.text,
'yearLevel': yearController.text,
'studentNumber': studentNumberController.text,
'college': collegeController.text,
});
if (!mounted) return;
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text('Student saved successfully!'),
),
);
nameController.clear();
courseController.clear();
yearController.clear();
studentNumberController.clear();
collegeController.clear();
},
child: const Text("Save Student"),
),
],
),
),
);
}
}