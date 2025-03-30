class ApiResponse<T> {
  final int code;
  final String? message;
  final T? result;

  ApiResponse({
    required this.code,
    this.message,
    this.result,
  });

  factory ApiResponse.fromJson(
      Map<String, dynamic> json, T Function(Object? json) fromJsonT) {
    return ApiResponse(
      code: json['code'] ?? 200,
      message: json['message'],
      result: json['result'] != null ? fromJsonT(json['result']) : null,
    );
  }

  Map<String, dynamic> toJson(Object Function(T value) toJsonT) {
    return {
      'code': code,
      'message': message,
      'result': result != null ? toJsonT(result as T) : null,
    };
  }
}
