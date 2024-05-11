import 'package:flutter/material.dart';
import 'package:jvn_info_get/screens/screen.dart';

void main() {
  runApp(const JvnInfoGetApp());
}

class JvnInfoGetApp extends StatelessWidget {
  const JvnInfoGetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Screen(),
    );
  }
}
