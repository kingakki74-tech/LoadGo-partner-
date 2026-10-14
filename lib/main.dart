import 'package:flutter/material.dart';
void main() {
runApp(const MyApp());
}
class MyApp extends StatelessWidget {
const MyApp({Key? key}) : super(key: key);
@override
Widget build(BuildContext context) {
return MaterialApp(
debugShowCheckedModeBanner: false,
home: Scaffold(
appBar: AppBar(
title: const Text('LoadGo Partner'),
backgroundColor: Colors.blue,
),
body: const Center(
child: Text(
'LoadGo Partner App',
style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
),
),
),
);
}
}
