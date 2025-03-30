// ignore: avoid_web_libraries_in_flutter
import 'dart:html';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:namer_app/api_service.dart';

class FileUploadWidget extends StatefulWidget {
  const FileUploadWidget({super.key});

  @override
  State<FileUploadWidget> createState() => _FileUploadWidgetState();
}

class _FileUploadWidgetState extends State<FileUploadWidget> {
  Uint8List? _fileBytes;
  String? _fileName;
  Uint8List? _videoBytes;
  String? _videoName;
  bool _isUploading = false;

  void _pickFile(bool isVideo) {
    final uploadInput = FileUploadInputElement();
    uploadInput.accept = isVideo ? 'video/*' : 'image/*';
    uploadInput.click();

    uploadInput.onChange.listen((e) {
      final files = uploadInput.files;
      if (files!.isNotEmpty) {
        final file = files[0];
        final reader = FileReader();

        reader.onLoadEnd.listen((e) {
          setState(() {
            if (isVideo) {
              _videoBytes = reader.result as Uint8List;
              _videoName = file.name;
            } else {
              _fileBytes = reader.result as Uint8List;
              _fileName = file.name;
            }
          });
        });

        reader.readAsArrayBuffer(file);
      }
    });
  }

  void _uploadFile() async {
    if (_fileBytes == null || _fileName == null) {
      print('File not selected or file name is null');
      return;
    }

    if (_videoBytes == null || _videoName == null) {
      print('Video not selected or video name is null');
      return;
    }

    setState(() {
      _isUploading = true; // Bắt đầu tải lên
    });

    try {
      await ApiService.uploadFile(
          fileBytes: _fileBytes!,
          fileName: _fileName!,
          videoBytes: _videoBytes!,
          videoName: _videoName!);
    } catch (e, stackTrace) {
      print('Upload failed with error: $e');
      print('Stack trace: $stackTrace');
    } finally {
      setState(() {
        _isUploading = false; // Kết thúc tải lên
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () => _pickFile(false),
          child: Text('Chọn hình ảnh'),
        ),
        if (_fileName != null) Text('Image: $_fileName'),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: () => _pickFile(true),
          child: Text('Chọn video'),
        ),
        if (_videoName != null) Text('Video: $_videoName'),
        SizedBox(height: 20),
        _isUploading
            ? CircularProgressIndicator() // Hiển thị bộ tải trong khi tải lên
            : ElevatedButton(
                onPressed: _uploadFile,
                child: Text('Tải lên'),
              ),
      ],
    );
  }
}
