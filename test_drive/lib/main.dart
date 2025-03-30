import 'package:flutter/material.dart';
import 'package:namer_app/file_upload_widget.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Flutter Web File Upload')),
        body: Center(
          child: FileUploadWidget(),
        ),
      ),
    );
  }
}
