import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:typed_data';

class ApiService {
  static const String _url = 'http://localhost:8070/movie/create';

  static Future<void> uploadFile({
    required Uint8List fileBytes,
    required String fileName,
    required Uint8List videoBytes,
    required String videoName,
  }) async {
    var request = http.MultipartRequest('POST', Uri.parse(_url));
    request.fields['title'] = 'Sample Title';
    request.fields['description'] = 'Sample Description';
    request.fields['director'] = 'Sample Director';
    request.fields['casts'] = 'Sample Casts';
    request.fields['duration'] = '120';
    request.fields['rating'] = '4.5';
    request.fields['releaseDate'] = '2022-01-01';
    request.fields['endDate'] = '2022-12-31';
    request.fields['genreIds'] = '1,2,3'; // Example of comma-separated values

    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        fileBytes,
        filename: fileName,
        contentType: MediaType('image', 'jpeg'),
      ),
    );

    request.files.add(
      http.MultipartFile.fromBytes(
        'video',
        videoBytes,
        filename: videoName,
        contentType: MediaType('video', 'mp4'),
      ),
    );

    var response = await request.send();

    if (response.statusCode == 200) {
      log('Upload succesfully!');
    } else {
      throw Exception(
          'Failed to upload file with status: ${response.statusCode}');
    }
  }
}
